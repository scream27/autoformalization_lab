# Hilbert scheme formalization: working instructions

## User goal and learning mode

- Main research goal: formalize smoothness of the Hilbert scheme of points on a smooth surface (Fogarty's theorem).
- The agent writes natural-language proofs, formalizes them in Lean, runs verification, and explains the correspondence in Korean. The user reads and understands; do not require the user to solve tactic exercises before proceeding.
- Explain what each definition represents, why each lemma is needed, and how to reproduce verification. Exercises are optional and only provided when requested.
- The earlier statement-only exercises in `AutoformalizationLab/Exercises/` are historical scaffolds. They do not determine the current teaching mode. MacMahon is a separate topic, not a prerequisite for this project.

## Scope and persistent plan

- Read `docs/hilbert-scheme/outline.md` and `docs/hilbert-scheme/verification.md` when starting work on this goal.
- Initial full-theorem scope: a smooth connected projective surface over ℂ; all natural numbers n, with n = 0 treated separately. The intended later extension is smooth quasi-projective surfaces. Do not silently claim the extension from the projective case.
- Mathematical roadmap: M0 statement/library audit → M1 explicit one-point algebra → M2 finite-length local algebra → M3 local Hom length bound → M4 Hilbert functor and representing scheme → M5 tangent-space identification and support decomposition → M6 reduced locus and connectedness → M7 dimension/regularity argument and smoothness.
- This roadmap is the Fogarty reference baseline. The current preferred implementation route is commuting operators plus explicit basis charts. Read `docs/hilbert-scheme/library-route-audit.md` for actual API checks, prototype results, and remaining gaps. Compare a rank-one algebraic ADHM smoothness bridge with direct commutator methods at the chart prototype stage; avoid assuming Luna/GIT or hyper-Kähler infrastructure is available.
- Implementation follows dependencies: cyclic representations → centralizers/trace duality → a small chart and its smoothness → arbitrary-n charts/representability → surface locality. Hilbert–Burch lifting remains a fallback candidate. Keep the mathematical target fixed and record blockers. Do not build a fake Hilbert scheme just to make a final theorem compile.
- Maintain the milestone table in the outline: planned, audited, conditional, verified, or blocked. Record actual file paths, theorem names, commands, and dependency gaps when available. “Audited” is not “implemented”.

## Mathematical fidelity

- Keep field, dimension, finite-type, projectivity, connectedness, length and support hypotheses explicit. Distinguish ring-module length from vector-space dimension, and explain when they agree.
- An ideal set or a vector space is not the representing Hilbert scheme. A tangent-vector model is not yet the scheme's tangent space; prove the bridge.
- A tangent-space upper bound alone does not prove smoothness. Establish the necessary local dimension lower bound and global component argument, then justify regularity → smoothness over ℂ.
- Avoid circular arguments: do not assume irreducibility or smoothness in the step meant to prove them.
- Mark intermediate theorems with unproved input hypotheses as conditional. Never report them as an unconditional proof of Fogarty's theorem. Track how each hypothesis will be discharged.
- Use primary mathematical sources and check scanned formulas visually when OCR is ambiguous. The reference proof is a guide, not a Lean-verified dependency.

## Lean implementation and verification

- Use the project's pinned Lean toolchain and Mathlib revision. Do not update them as a routine troubleshooting step.
- Search the local Mathlib source first with `rg`. Confirm exact imports and declaration types with a small `#check` file in this environment. Do not invent lemma names from memory.
- `exact?`, `apply?`, and `rw?` are search aids; compile the resulting proof again.
- Put completed new code under `AutoformalizationLab/HilbertScheme/`. Add finished modules to the library import graph so CI checks them. Keep exploratory files and unfinished exercises separate.
- Completed modules must have no `sorry`, `admit`, or project-added mathematical axioms. Check both source and `#print axioms` of exported theorems. Normal Lean foundations (`propext`, `Classical.choice`, `Quot.sound`) may occur; `sorryAx` or an unexplained extra axiom prevents a completed claim.
- Compile each changed file and run the appropriate `lake build` target. Record exact results and distinguish a checked statement, a conditional proof, and an unconditional proof.
- Explain semantic review as well as kernel checking: Lean verifies the encoded statement; humans must check that the encoding matches the mathematical target.
- Reports must identify what was actually verified and what remains missing. Do not equate a successful documentation workflow with proof verification.

## Next action

Start the matrix route with cyclic representations and the explicit quotient `(x²,xy,y²)`, explaining the origin `(x,y)` case when helpful. Use `docs/hilbert-scheme/RouteAudit.lean` as a checked prototype, not as an existing proof of geometric smoothness. Promote reusable results into the library only with clear statements and verification. Before treating a matrix rank computation as smoothness, construct the scheme/presentation bridge. Basis charts must work for families, not only closed points.
