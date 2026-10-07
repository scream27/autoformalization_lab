module

public import Mathlib.Algebra.BigOperators.Group.Finset.Basic
public import Mathlib.Tactic.Ring

set_option linter.style.header false

/-! Exercise 2: the first n odd numbers add up to n squared.
The n = 0 case includes an empty sum. Replace only the `sorry`. -/

public section

open scoped BigOperators

namespace AutoformalizationLab.Exercises

theorem sum_first_odds (n : ℕ) :
    (∑ k ∈ Finset.range n, (2 * k + 1)) = n ^ 2 := by
  sorry

end AutoformalizationLab.Exercises
