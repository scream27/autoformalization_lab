module

public import Mathlib.Data.Nat.Basic
public import Lean.Elab.Tactic.LibrarySearch
public import Lean.Elab.Tactic.Rewrites

set_option linter.style.header false

/-! Search tactics are executed in the actual pinned environment.
Their `Try this:` messages are installation checks, not warm-up solutions. -/

public section

namespace AutoformalizationLab

example (a b : ℕ) : a + b = b + a := by
  exact?

example (a b : ℕ) : a + b = b + a := by
  apply?

example (n : ℕ) : n + 0 = n := by
  rw?

end AutoformalizationLab
