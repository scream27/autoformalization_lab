module

public import Mathlib.RingTheory.PowerSeries.Inverse
public import Mathlib.Algebra.Order.Field.Rat
public import Mathlib.Algebra.BigOperators.Group.Finset.Basic

set_option linter.style.header false

/-! Exercise 3: define the MacMahon formal power series.
No solution definitions or counting theorem are supplied.
Each `sorry` is an exercise hole, not a validated implementation. -/

public noncomputable section

open scoped BigOperators

namespace AutoformalizationLab.Exercises

-- Target: factor k = (1 - X^(k+1))^(-(k+1)), using a natural power of an inverse.
def macMahonFactor (k : ℕ) : PowerSeries ℚ := by
  sorry

-- Target: multiply factors indexed by k = 0, ..., N-1; N = 0 is the empty product.
def macMahonPartial (N : ℕ) : PowerSeries ℚ := by
  sorry

-- Target: the coefficient of degree n is the coefficient of degree n
-- in macMahonPartial n. Construct a series with those coefficients.
def macMahon : PowerSeries ℚ := by
  sorry

end AutoformalizationLab.Exercises
