import Mathlib.LinearAlgebra.Matrix.Trace
import Mathlib.LinearAlgebra.FiniteDimensional.Lemmas
import Mathlib.Algebra.MvPolynomial.Eval
import Mathlib.RingTheory.Smooth.StandardSmoothCotangent
import Mathlib.RingTheory.RegularLocalRing.Defs

/-! Reproducible API audit and small algebra prototype, not Hilbert scheme smoothness. -/

#check Matrix.ext_iff_trace_mul_left
#check Matrix.trace_mul_cycle
#check LinearMap.finrank_range_add_finrank_ker
#check Submodule.finrank_quotient_add_finrank
#check LinearMap.ext_on_range
#check Algebra.isMulCommutative_adjoin
#check MvPolynomial.aeval
#check Algebra.FormallySmooth.iff_comp_surjective
#check Algebra.SubmersivePresentation.isStandardSmooth
#check Algebra.PreSubmersivePresentation.isUnit_jacobian_iff_aevalDifferential_bijective
#check IsRegularLocalRing.iff_finrank_cotangentSpace

namespace AutoformalizationLab.RouteAudit

open scoped IsMulCommutative in
/-- Evaluate commuting operators through the commutative subalgebra they generate. -/
noncomputable def commutingEvaluation
    {k A σ : Type*} [Field k] [Ring A] [Algebra k A]
    (B : σ → A) (hc : (Set.range B).Pairwise Commute) : MvPolynomial σ k →ₐ[k] A := by
  letI := Algebra.isMulCommutative_adjoin k hc
  exact (Algebra.adjoin k (Set.range B)).val.comp
    (MvPolynomial.aeval (fun s => ⟨B s, Algebra.subset_adjoin ⟨s, rfl⟩⟩))

/-- The existing standard-smooth API really supplies smoothness by typeclass inference. -/
example {R S : Type*} [CommRing R] [CommRing S] [Algebra R S]
    [Algebra.IsStandardSmooth R S] : Algebra.Smooth R S := inferInstance

/-- On a cyclic representation, a commuting endomorphism is determined by the generator. -/
theorem cyclic_endomorphism_ext
    {k A V : Type*} [Field k] [Semiring A] [Algebra k A]
    [AddCommGroup V] [Module k V]
    (ρ : A →ₐ[k] Module.End k V) (v : V)
    (hcyclic : Submodule.span k (Set.range (fun a : A => ρ a v)) = ⊤)
    (g h : Module.End k V)
    (hg : ∀ a, Commute g (ρ a)) (hh : ∀ a, Commute h (ρ a))
    (hv : g v = h v) : g = h := by
  apply LinearMap.ext_on_range hcyclic
  intro a
  calc
    g (ρ a v) = ρ a (g v) := congrArg (fun f : Module.End k V => f v) (hg a).eq
    _ = ρ a (h v) := congrArg (ρ a) hv
    _ = h (ρ a v) := (congrArg (fun f : Module.End k V => f v) (hh a).eq).symm

/-- The trace pairing separates matrices; this is the duality needed in the matrix route. -/
theorem trace_pairing_separates
    {k ι : Type*} [Field k] [Fintype ι] [DecidableEq ι]
    (A : Matrix ι ι k) (h : ∀ B : Matrix ι ι k, Matrix.trace (B * A) = 0) :
    A = 0 := by
  apply Matrix.ext_iff_trace_mul_left.mpr
  intro B
  simpa using h B

#print axioms cyclic_endomorphism_ext
#print axioms trace_pairing_separates

end AutoformalizationLab.RouteAudit
