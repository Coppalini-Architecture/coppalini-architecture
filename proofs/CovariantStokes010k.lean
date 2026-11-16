import Init.Data.Rat.Basic
import proofs.MetricVolume010k
import proofs.PalatiniBoundary010i

/-!
# Minimum Mechanics 010k — covariant volume–Stokes on a nontrivial jet algebra

FIXED SOURCES
010j supplies the explicit Palatini current; 010i supplies the boundary
reader; 010e supplies a 3-direction nonzero differential algebra. The
010k metric determinant supplies the pointwise traceΓ volume law.

CONCRETE INSTANCE
Work in A = ℤ[ε₀,ε₁,ε₂]/(εᵢ εⱼ). The first-order volume element
   ν = 1 + 2ε₀ - ε₁ + 3ε₂
has a NONZERO derivative and compatible connection-trace fields
   Γ_i = D_iν,
   D_iν = ν Γ_i.
For every Jet3 lapse N and current J^i, prove the actual weighted
Leibniz identity
   D_i(ν N J^i) = ν N (D_i J^i + Γ_i J^i) + ν (D_iN)J^i.
Together with the inherited explicit boundary functional, this gives
the covariant Stokes transfer in three directions:
   ∫ ν N ∇_i J^i = boundary(ν N J) - ∫ ν (D_iN) J^i.

No smooth manifold or physical Riemannian measure is constructed by
this finite jet example. The nonzero boundary cannot be suppressed.
No new axioms, Mathlib, or sorry.
-/

set_option autoImplicit false

namespace CovariantStokes010k
open JetStokes010e
open PalatiniBoundary010i

abbrev Axis := Fin 3

def volume : Jet3 := ⟨1,2,-1,3⟩
def traceGamma (i : Axis) : Jet3 := JetStokes010e.D i volume

def multiply := JetStokes010e.mul
def plus := JetStokes010e.add
def derivative := JetStokes010e.D

private theorem axes : ∀ i : Axis, i = 0 ∨ i = 1 ∨ i = 2 := by decide

theorem volume_nonconstant : derivative 0 volume ≠ JetStokes010e.zero := by decide

theorem volume_trace_compatible (i : Axis) :
    derivative i volume = multiply volume (traceGamma i) := by
  rcases axes i with hi | hi | hi <;> subst i <;>
    decide

def covDivergence (i : Axis) (J : Jet3) : Jet3 :=
  plus (derivative i J) (multiply (traceGamma i) J)

def densityCurrent (N J : Jet3) : Jet3 :=
  multiply volume (multiply N J)

def normalIntegrand (i : Axis) (N J : Jet3) : Jet3 :=
  multiply volume (multiply N (covDivergence i J))

def gradientIntegrand (i : Axis) (N J : Jet3) : Jet3 :=
  multiply volume (multiply (derivative i N) J)

-- At each of the three coordinate addresses, the statement is
-- exact for arbitrary integer coefficients of N and J.
theorem densitized_current_derivative
    (i : Axis) (N J : Jet3) :
    derivative i (densityCurrent N J) =
      plus (normalIntegrand i N J) (gradientIntegrand i N J) := by
  rcases axes i with hi | hi | hi <;>
    subst i <;>
    cases N with
    | mk nc nx ny nz =>
      cases J with
      | mk jc jx jy jz =>
        simp [derivative, densityCurrent, normalIntegrand,
          gradientIntegrand, covDivergence, volume, traceGamma,
          multiply, plus, JetStokes010e.D,
          JetStokes010e.mul, JetStokes010e.add,
          Int.mul_left_comm nc 2 jc,
          Int.mul_left_comm nc (-1) jc,
          Int.mul_left_comm nc 3 jc,
          Int.mul_neg, Int.neg_mul] <;> omega

def integral (f : Jet3) : Int := integralJet f
def boundary (i : Axis) (f : Jet3) : Int := boundaryJet i f

theorem weighted_covariant_stokes_one
    (i : Axis) (N J : Jet3) :
    integral (normalIntegrand i N J) +
      integral (gradientIntegrand i N J) =
        boundary i (densityCurrent N J) := by
  have hx := congrArg integralJet
    (densitized_current_derivative i N J)
  change integralJet (JetStokes010e.D i (densityCurrent N J)) =
      integralJet (JetStokes010e.add (normalIntegrand i N J)
        (gradientIntegrand i N J)) at hx
  rw [integralJet_add] at hx
  have hb := jet_boundary_stokes i (densityCurrent N J)
  simpa only [integral, boundary] using hx.symm.trans hb

def sum3 (f : Axis → Int) : Int := f 0 + f 1 + f 2

def normalTotal (N : Jet3) (J : Axis → Jet3) : Int :=
  sum3 (fun i => integral (normalIntegrand i N (J i)))

def gradientTotal (N : Jet3) (J : Axis → Jet3) : Int :=
  sum3 (fun i => integral (gradientIntegrand i N (J i)))

def boundaryTotal (N : Jet3) (J : Axis → Jet3) : Int :=
  sum3 (fun i => boundary i (densityCurrent N (J i)))

theorem weighted_covariant_stokes_three
    (N : Jet3) (J : Axis → Jet3) :
    normalTotal N J = boundaryTotal N J - gradientTotal N J := by
  have h0 := weighted_covariant_stokes_one 0 N (J 0)
  have h1 := weighted_covariant_stokes_one 1 N (J 1)
  have h2 := weighted_covariant_stokes_one 2 N (J 2)
  simp only [normalTotal, gradientTotal, boundaryTotal, sum3]
  omega

theorem closed_boundary_transfer
    (N : Jet3) (J : Axis → Jet3)
    (hZero : boundaryTotal N J = 0) :
    normalTotal N J = -gradientTotal N J := by
  rw [weighted_covariant_stokes_three, hZero]
  omega

-- A witnessed nonzero flux excludes an inadmissible blanket erasure
-- of the boundary term, even with a nonconstant volume.
def witnessCurrent : Axis → Jet3 :=
  fun i => if i=0 then epsX else JetStokes010e.zero

theorem nonzero_boundary_witness :
    normalTotal one witnessCurrent = 1 ∧
    gradientTotal one witnessCurrent = 0 ∧
    boundaryTotal one witnessCurrent = 1 := by
  decide

theorem boundary_cannot_be_erased :
    normalTotal one witnessCurrent ≠ -gradientTotal one witnessCurrent := by
  decide

#print axioms volume_trace_compatible
#print axioms volume_nonconstant
#print axioms densitized_current_derivative
#print axioms weighted_covariant_stokes_one
#print axioms weighted_covariant_stokes_three
#print axioms closed_boundary_transfer
#print axioms nonzero_boundary_witness
#print axioms boundary_cannot_be_erased

end CovariantStokes010k
