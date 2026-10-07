module

public import Mathlib.Data.Nat.Basic

set_option linter.style.header false

/-! Exercise 1: turn a conjunction around. Replace only the `sorry`.
This file is a checked exercise statement, not a completed proof. -/

public section

namespace AutoformalizationLab.Exercises

theorem and_swap (P Q : Prop) : P ∧ Q → Q ∧ P := by
  sorry

end AutoformalizationLab.Exercises
