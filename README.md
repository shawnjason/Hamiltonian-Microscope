# Hamiltonian-Microscope — Lean Proofs

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.20073715.svg)](https://doi.org/10.5281/zenodo.20073715)

Machine-checked Lean 4 proofs for:

**"Minimal Topologies of Forward-Local Failure in AI Systems: The Hamiltonian Microscop"**

Paper DOI (concept, always resolves to latest): [TBD](https://doi.org/10.5281/zenodo.20278073)

---

## Author

Shawn Kevin Jason — Independent Researcher, Las Vegas, NV
ORCID: [![ORCID iD](https://orcid.org/sites/default/files/images/orcid_16x16.png)](https://orcid.org/0009-0003-9208-1556) [0009-0003-9208-1556](https://orcid.org/0009-0003-9208-1556)

---

## What This Repository Contains

Two standalone Lean 4 proof files covering the principal formal results of the paper. The proofs split into two groups: a **constraint-system instantiation** establishing that the 4×4 Hamiltonian path-game (and any Hamiltonian-path-style domain) is an instance of the abstract ConstraintSystem framework from Sudoku-Microscope, thereby inheriting all four structural theorems (local-global separation, catastrophic-commitment foreclosure, forced-gate safety, bucket sufficiency) without redundant proof; and a **Layer 2 signature formalization** defining the silent-commit signature — commit at a multi-candidate cell without positive admissibility evidence for the committed tuple — as a formal predicate and establishing its provider-agnostic well-definedness.

Each file is independent and verifies against the current Mathlib release.

---

## Files

### Constraint-System Instantiation

**`252_hamiltonian_constraint_system.lean`** — Path-Game Is a Constraint System
Defines an abstract `PathGame` structure with partial-path states, vertex moves, Hamiltonian-path completions, and the two ConstraintSystem axioms: coherence (completions imply local validity) and monotonicity (extending a partial path can only restrict the completion set). Provides the `PathGame.toConstraintSystem` constructor establishing the formal connection. As a consequence, the four Sudoku-Microscope theorems — local-global separation (IDs 247, 248), catastrophic-commitment foreclosure (ID 249), forced-gate safety (ID 250), and bucket sufficiency (ID 251) — apply to path-games by inheritance. The 4×4 instance (start = r1c1, finish = r1c4, exactly 8 valid Hamiltonian paths A–H) is one concrete instantiation; the framework covers any Hamiltonian-path problem on any graph.

### Layer 2 Signature Formalization

**`253_layer2_signature.lean`** — Layer 2 Silent-Commit Signature (Definition and Well-Definedness)
Defines the Layer 2 silent-commit signature as a formal predicate: a catastrophic commit satisfies the signature iff it occurs at a multi-candidate cell (multiple locally valid moves exist) AND the committed (cell, digit) tuple lacks positive admissibility evidence. Establishes well-definedness: the predicate depends only on the evidence record and the local-validity structure of the state, not on which model or provider produced the trajectory. This is Paper 8's novel formal concept — the 195/195 cross-provider replication (ID 261) is the empirical finding that all observed catastrophic commits satisfy this signature; the Lean file formalizes the signature itself as a provider-agnostic structural predicate.

---

## Mapping to the Paper

| Paper Result | File | Lean Theorem |
|---|---|---|
| Path-game domain as ConstraintSystem instance (§2) | `252_hamiltonian_constraint_system.lean` | `PathGame.toConstraintSystem` |
| Layer 2 silent-commit signature definition (§3.1) | `253_layer2_signature.lean` | `layer2Signature` (definition) |
| Layer 2 signature provider-agnostic well-definedness (§3.1) | `253_layer2_signature.lean` | `layer2_provider_agnostic` |

---

## How to Verify

1. Open [live.lean-lang.org](https://live.lean-lang.org)
2. Confirm the dropdown in the upper right is set to **Latest Mathlib**
3. Paste the contents of any `.lean` file into the editor
4. Wait for checking to complete — "No goals" on each theorem and no errors in the Problems pane confirms verification

Each file is independent; no cross-file imports are required.

---

## Scope

These proofs verify the formal instantiation of the constraint-system framework for path-games and the well-definedness of the Layer 2 silent-commit signature. They do not establish:

- The empirical cross-provider replication (195/195 catastrophic commits satisfying Layer 2 across GPT-5.5 and Claude corpora) — this is an empirical finding, not a theorem
- Claude default-mode determinism, Path D convergence, nonce-perturbation sensitivity, solve-rate divergences, or verification-pattern attractors — these are empirical observations specific to the tested provider instances
- The conjectures about optional/named_dummy mechanism ambiguity, temporal perturbation lock-in, or alternate-instance generalization
- The governance and provenance rules (frozen protocol, claims register, broken-bat exclusion) — these are methodological constraints, not formal theorems

The four Sudoku-Microscope structural theorems (local-global separation, catastrophic-commitment foreclosure, forced-gate safety, bucket sufficiency) are NOT re-proved in this repository. They are inherited by the ConstraintSystem instantiation in file 252.

---

## Related Work

The abstract ConstraintSystem framework and its four structural theorems are developed in:

*Sudoku as a Microscope for Non-Extendable Commitment: Empirical Validation of Global Admissibility Filtering* — DOI: TBD (Lean proofs: TBD)

The foundational projection-theoretic result is developed in:

*Projection Insufficiency and Trajectory Realization* — [DOI: 10.5281/zenodo.19633241](https://doi.org/10.5281/zenodo.19633241) (Lean proofs: [10.5281/zenodo.19687629](https://doi.org/10.5281/zenodo.19687629))

The forward-case impossibility result is developed in:

*The Non-Locality of Extendability* — [DOI: 10.5281/zenodo.19688367](https://doi.org/10.5281/zenodo.19688367) (Lean proofs: [10.5281/zenodo.19687799](https://doi.org/10.5281/zenodo.19687799))

The stochastic extension is developed in:

*Inconsistency Accumulation in Forward-Local Sequential Policies* — [DOI: 10.5281/zenodo.19688628](https://doi.org/10.5281/zenodo.19688628) (Lean proofs: [10.5281/zenodo.19687094](https://doi.org/10.5281/zenodo.19687094))

The language-model specialization is developed in:

*Language Model Hallucinations* — [DOI: 10.5281/zenodo.19715059](https://doi.org/10.5281/zenodo.19715059) (Lean proofs: [10.5281/zenodo.20059771](https://doi.org/10.5281/zenodo.20059771))

The RLM theoretical analysis is developed in:

*Recursive Language Models Through the Admissibility-Dynamics Framework* — [DOI: 10.5281/zenodo.19753549](https://doi.org/10.5281/zenodo.19753549) (Lean proofs: [10.5281/zenodo.20060154](https://doi.org/10.5281/zenodo.20060154))

The OOLONG-Pairs empirical companion is developed in:

*From Recursive Scaffolding to Admissibility-First Construction* — DOI: TBD (Lean proofs: TBD)

---

## License

MIT
