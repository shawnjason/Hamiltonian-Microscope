/-
  253_layer2_signature.lean

  Hamiltonian-Microscope (Paper 8) — abstract formalization, file 2/2.

  Catalog entries covered:
    • ID 253 — Layer 2 silent-commit signature definition
    • ID 254 — Positive admissibility evidence criterion
                (definitional companion to ID 253)
    • ID 262 — Signature locality lemma: signature is local to the
                failing commit, not global to the run
    • ID 263 — Rider: indeterminate tool responses are not positive
                admissibility evidence
    • ID 283 — Rider: tool emission alone is not positive admissibility
                evidence (positive evidence requires affirmation)

  Per-file standalone: the `ConstraintSystem` structure is repeated here
  in the unified five-field form shared with the Sudoku-Microscope
  (Paper 7) and Hamiltonian-Microscope file 1 (252) formalizations.

  This is the central novel formal contribution of Paper 8. The
  empirical 195/195 cross-provider replication (ID 261) is the claim
  that every observed catastrophic commit across GPT-5.5 and Claude
  Opus 4.7 satisfies the predicate defined here. Defining the
  predicate as a function of (cs, evidence record, s, m) only — with
  no provider, model identifier, or trajectory provenance parameter —
  makes the cross-provider unification claim provider-agnostic by
  construction, and makes locality (ID 262) a one-line theorem.

  Author: Shawn Kevin Jason  (ORCID 0009-0003-9208-1556)
  Repo:   github.com/shawnjason/Hamiltonian-Microscope
-/

import Mathlib

namespace HamiltonianMicroscope.Layer2Signature

/-- Abstract constraint system. Unified five-field structure shared
    across the Sudoku-Microscope (Paper 7) and Hamiltonian-Microscope
    (Paper 8) formalizations. Each file declares this structure
    independently for per-file standalone verification. -/
structure ConstraintSystem (State Move Completion : Type) where
  locallyValid       : State → Move → Prop
  apply              : State → Move → State
  comp               : State → Finset Completion
  comp_implies_local : ∀ (s : State) (m : Move) (c : Completion),
                        c ∈ comp (apply s m) → locallyValid s m
  comp_monotone      : ∀ (s : State) (m : Move),
                        comp (apply s m) ⊆ comp s

/-- A single tool interaction recorded during a run. Models a tool
    call and its response.

    Fields:
    • `refersTo`             — the (state, move) tuple this interaction
                                concerned. Tuple-specificity is enforced
                                by the equality check in
                                `hasPositiveEvidence` (ID 254): an
                                interaction about a different tuple
                                cannot witness evidence for `(s, m)`.
    • `determinate`          — whether the response was well-defined
                                (not an indeterminate/error/timeout).
                                Required by rider ID 263.
    • `affirmsAdmissibility` — whether the response actually affirmed
                                admissibility for `refersTo`. Required
                                by rider ID 283: tool emission alone
                                without affirmation is not evidence. -/
structure ToolInteraction (State Move : Type) where
  refersTo             : State × Move
  determinate          : Prop
  affirmsAdmissibility : Prop

/-- An evidence record is a set of tool interactions accumulated during
    a run. Different model trajectories (GPT-5.5, Claude Opus 4.7, etc.)
    produce different evidence records over the same domain; the Layer 2
    signature predicate (below) is defined so that only the record's
    content at the specific commit affects its verdict. -/
abbrev EvidenceRecord (State Move : Type) := Set (ToolInteraction State Move)

/-- **Positive admissibility evidence criterion** (Paper 8, ID 254).

    A move `(s, m)` has positive admissibility evidence in record `er`
    iff `er` contains a tool interaction that:
      (a) refers to exactly `(s, m)`        — tuple-specificity (ID 254)
      (b) is determinate                     — rider (ID 263)
      (c) affirms admissibility              — rider (ID 283)

    All three conjuncts are required. The riders (b) and (c) are baked
    into the definition: an indeterminate response cannot witness this
    predicate (rider ID 263), and a tool emission without affirmation
    cannot witness it either (rider ID 283). The two riders are then
    obtainable as small theorems below. -/
def hasPositiveEvidence {State Move : Type}
    (er : EvidenceRecord State Move) (s : State) (m : Move) : Prop :=
  ∃ ti ∈ er, ti.refersTo = (s, m) ∧ ti.determinate ∧ ti.affirmsAdmissibility

/-- A state is a **multi-candidate** state iff at least two distinct
    moves are locally valid from it. Multi-candidacy is the structural
    necessary condition for a commit to be a *choice* rather than a
    forced move. The Layer 2 signature requires multi-candidacy because
    a forced commit (only one option) cannot be a "silent commit" —
    there was no choice to verify. -/
def multiCandidate {State Move Completion : Type}
    (cs : ConstraintSystem State Move Completion) (s : State) : Prop :=
  ∃ m₁ m₂ : Move, m₁ ≠ m₂ ∧ cs.locallyValid s m₁ ∧ cs.locallyValid s m₂

/-- **Layer 2 silent-commit signature** (Paper 8, ID 253).

    A commit `(s, m)` satisfies the Layer 2 signature iff:
      (a) state `s` is multi-candidate (the commit was a choice), AND
      (b) no positive admissibility evidence was acquired for `(s, m)`
          in the run's evidence record.

    This is the central novel formal concept of Paper 8. The empirical
    finding (195/195 across GPT-5.5 + Claude Opus 4.7, ID 261) is that
    every catastrophic commit observed satisfies this predicate.
    Formalizing the predicate as a function of `(cs, er, s, m)` only —
    with no provider, model identifier, or trajectory provenance
    parameter — makes the cross-provider unification claim
    provider-agnostic by construction (Paper 8, §4, ID 271). -/
def layer2Signature {State Move Completion : Type}
    (cs : ConstraintSystem State Move Completion)
    (er : EvidenceRecord State Move)
    (s : State) (m : Move) : Prop :=
  multiCandidate cs s ∧ ¬hasPositiveEvidence er s m

/-- **Signature locality lemma** (Paper 8, ID 262).

    The Layer 2 signature at commit `(s, m)` is determined entirely by
    the constraint system, the evidence record's content *at the
    specific commit* `(s, m)`, and the state-move pair itself. Two
    evidence records that agree on the commit's evidence status give
    the same signature verdict, regardless of how they differ elsewhere
    in the run.

    This formalizes the empirical claim that the signature is local to
    the failing commit, not global to the run: a model can verify
    elsewhere in the trajectory and still satisfy the signature at the
    failing commit, because the predicate factors through the per-commit
    evidence rather than aggregating over the run. The same theorem
    delivers provider-agnosticism: two providers' evidence records
    agreeing on the commit yield the same verdict.

    Proof: unfold `layer2Signature` to its conjunction form, then
    rewrite the second conjunct using the hypothesis. -/
theorem layer2_signature_local
    {State Move Completion : Type}
    (cs : ConstraintSystem State Move Completion)
    (er₁ er₂ : EvidenceRecord State Move)
    (s : State) (m : Move)
    (h_same_evidence :
      hasPositiveEvidence er₁ s m ↔ hasPositiveEvidence er₂ s m) :
    layer2Signature cs er₁ s m ↔ layer2Signature cs er₂ s m := by
  simp only [layer2Signature, h_same_evidence]

/-- **Rider** (Paper 8, ID 263): indeterminate tool responses are not
    positive admissibility evidence.

    Statement: if every interaction in `er` referring to `(s, m)` is
    indeterminate, then `(s, m)` has no positive evidence. Equivalently:
    a witness of `hasPositiveEvidence` must be determinate. Forced by
    the conjunction structure of `hasPositiveEvidence`'s definition —
    `determinate` is one of the required conjuncts. -/
theorem indeterminate_not_evidence
    {State Move : Type}
    (er : EvidenceRecord State Move)
    (s : State) (m : Move)
    (h_all_indeterminate :
      ∀ ti ∈ er, ti.refersTo = (s, m) → ¬ti.determinate) :
    ¬hasPositiveEvidence er s m := by
  rintro ⟨ti, h_in, h_refers, h_det, -⟩
  exact h_all_indeterminate ti h_in h_refers h_det

/-- **Rider** (Paper 8, ID 283): tool emission alone is not positive
    admissibility evidence.

    Statement: if every interaction in `er` referring to `(s, m)` fails
    to affirm admissibility, then `(s, m)` has no positive evidence.
    Equivalently: a tool was emitted but produced no affirmation —
    insufficient. Forced by the conjunction structure of
    `hasPositiveEvidence`: `affirmsAdmissibility` is one of the required
    conjuncts. -/
theorem emission_without_affirmation_not_evidence
    {State Move : Type}
    (er : EvidenceRecord State Move)
    (s : State) (m : Move)
    (h_no_affirmations :
      ∀ ti ∈ er, ti.refersTo = (s, m) → ¬ti.affirmsAdmissibility) :
    ¬hasPositiveEvidence er s m := by
  rintro ⟨ti, h_in, h_refers, -, h_affirm⟩
  exact h_no_affirmations ti h_in h_refers h_affirm

end HamiltonianMicroscope.Layer2Signature