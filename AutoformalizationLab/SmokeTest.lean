module

public import Mathlib.Data.Nat.Basic
public import Mathlib.Algebra.Order.Field.Rat
public import Mathlib.Tactic.NormNum
public import Mathlib.Tactic.Linarith

set_option linter.style.header false

/-! Step 1 installation checks, separate from the Step 2 exercises. -/

public section

namespace AutoformalizationLab

#eval (1 + 1 : Nat)
#check ℚ

theorem smoke_arithmetic : (2 : ℕ) + 3 = 5 := by
  norm_num

theorem smoke_order (a b : ℚ) (h : a + 1 ≤ b) : a ≤ b := by
  linarith

#print axioms smoke_arithmetic
#print axioms smoke_order

end AutoformalizationLab
