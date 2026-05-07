/-
  252_hamiltonian_constraint_system.lean

  Hamiltonian-Microscope (Paper 8) — abstract formalization, file 1/2.

  Catalog entry covered:
    • ID 252  — Hamiltonian game as an instance of the ConstraintSystem
                framework

  Per-file standalone: the `ConstraintSystem` structure is repeated here
  in the unified five-field form shared with the Sudoku-Microscope
  (Paper 7) formalization. Hamiltonian games are exhibited as an
  instance via the `HamiltonianGame.toConstraintSystem` constructor.
  Through this instance, all four Paper 7 abstract theorems
  (local-global separation; catastrophic commitment foreclosure;
  forced-gate safety; bucket sufficiency) specialize to Hamiltonian
  games at no additional proof cost — the constructor itself is the
  theorem that Hamiltonian games satisfy the framework.

  Author: Shawn Kevin Jason  (ORCID 0009-0003-9208-1556)
  Repo:   github.com/shawnjason/Hamiltonian-Microscope
-/

import Mathlib

namespace HamiltonianMicroscope.HamiltonianGameConstraintSystem

/-- Abstract constraint system. Unified five-field structure shared with
    the Sudoku-Microscope (Paper 7) formalization. Each file in the
    framework declares this same structure independently for per-file
    standalone verification; theorems within each file use only the
    subset of fields they need.

    Fields:
    • `locallyValid`       — predicate: move `m` is locally legal at `s`.
    • `apply`              — state transition under a move.
    • `comp`               — completion set: full extensions of the state.
    • `comp_implies_local` — coherence: any completion of the post-move
                              state witnesses local validity of the move.
    • `comp_monotone`      — restriction: each move can only narrow the
                              completion set, never widen it. -/
structure ConstraintSystem (State Move Completion : Type) where
  locallyValid       : State → Move → Prop
  apply              : State → Move → State
  comp               : State → Finset Completion
  comp_implies_local : ∀ (s : State) (m : Move) (c : Completion),
                        c ∈ comp (apply s m) → locallyValid s m
  comp_monotone      : ∀ (s : State) (m : Move),
                        comp (apply s m) ⊆ comp s

/-- A Hamiltonian game over a vertex type `V`. Captures Hamiltonian-path
    domains abstractly: the Hamiltonian game tracks partial paths
    (prefixes of vertex sequences from a designated start), full
    Hamiltonian paths (completions to a designated end), and the
    structural constraints that govern legal extensions.

    Fields:
    • `PartialPath`        — type of in-progress paths from the start
                             vertex.
    • `HamiltonianPath`    — type of complete Hamiltonian paths from
                             start to end.
    • `applyVertex`        — extend a partial path by appending one vertex.
    • `validNextVertex`    — predicate: whether `v` is a legal next move
                             from the current partial path (adjacent to
                             the current end, not yet visited, etc.).
    • `fullPathsExtending` — completion set: full Hamiltonian paths that
                             extend the partial path as a prefix.

    Axioms:
    • `full_path_implies_valid_next` — coherence: if any full Hamiltonian
      path extends the post-move partial path, then the move was a legal
      next vertex (the move respected adjacency, non-revisitation, etc.).
    • `fullPaths_monotone` — restriction: extending the partial path can
      only narrow the set of full extensions, never widen it. Once a
      vertex is committed, completions disagreeing with that commit are
      removed from the extension set forever. -/
structure HamiltonianGame (V : Type) where
  PartialPath         : Type
  HamiltonianPath     : Type
  applyVertex         : PartialPath → V → PartialPath
  validNextVertex     : PartialPath → V → Prop
  fullPathsExtending  : PartialPath → Finset HamiltonianPath
  full_path_implies_valid_next :
    ∀ (p : PartialPath) (v : V) (h : HamiltonianPath),
      h ∈ fullPathsExtending (applyVertex p v) → validNextVertex p v
  fullPaths_monotone :
    ∀ (p : PartialPath) (v : V),
      fullPathsExtending (applyVertex p v) ⊆ fullPathsExtending p

/-- **Hamiltonian Game as a Constraint System** (Paper 8, ID 252).

    Every `HamiltonianGame V` is an instance of the `ConstraintSystem`
    framework. The mapping is purely structural: `validNextVertex`
    becomes `locallyValid`, `applyVertex` becomes `apply`,
    `fullPathsExtending` becomes `comp`, and the two HamiltonianGame
    axioms become the two ConstraintSystem axioms. The constructor
    below is the theorem.

    **Inheritance.** Through this instance, the four abstract
    Sudoku-Microscope theorems specialize to Hamiltonian games at zero
    additional proof cost:
      – local-global separation (Paper 7, IDs 247–248)
      – catastrophic commitment foreclosure (Paper 7, IDs 217 + 249)
      – forced-gate safety (Paper 7, ID 250)
      – bucket sufficiency (Paper 7, ID 251)

    The Hamiltonian-Microscope work inherits the Sudoku-Microscope
    theorem catalog through this single constructor; the empirical
    cross-provider Layer 2 signature replication (195/195) of Paper 8
    is then an instance of these abstract guarantees. -/
def HamiltonianGame.toConstraintSystem {V : Type} (hg : HamiltonianGame V) :
    ConstraintSystem hg.PartialPath V hg.HamiltonianPath where
  locallyValid       := hg.validNextVertex
  apply              := hg.applyVertex
  comp               := hg.fullPathsExtending
  comp_implies_local := hg.full_path_implies_valid_next
  comp_monotone      := hg.fullPaths_monotone

end HamiltonianMicroscope.HamiltonianGameConstraintSystem