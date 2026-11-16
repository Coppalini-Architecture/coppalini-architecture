import Init.Data.Rat.Basic
import proofs.CurvedEH010i
import proofs.JetStokes010e

/-!
# Minimum Mechanics 010i — Palatini boundary interface and visible flux

For the gravitational curvature first variation, the Palatini contracted
divergence is represented by the vector current
  J^k = g^{lj} δΓ^k_{jl} - g^{lk} δΓ^j_{jl}.
The boundary operator is an explicit part of the functional reader:
  integral(∂_i f) = boundary_i(f).
Combining that relation with the exact Leibniz rule proves
  integral(N ∂_i J^i)
      = boundary_i(N J^i) - integral((∂_i N) J^i).
The three spatial directions are summed without a hidden boundary premise.

A concrete nonzero-boundary example uses the certified 010e Jet3 algebra
and a functional that reads its constant plus linear coefficients.

SCOPE: The generic algebraic divergence identity is certified, and the
Palatini current is explicitly indexed. Identification with the
covariant divergence on an arbitrary smooth Riemannian 3-manifold,
including metric-compatible tensor density transport and the smooth
boundary normal form, is OPEN. Nonzero boundary data are retained.

No Mathlib, no sorry, no new axioms.
-/
set_option autoImplicit false

namespace PalatiniBoundary010i

abbrev Axis := Fin 3
open MetricInverse010i

structure BoundarySlice (F : Type) where
  addField : F → F → F
  mulField : F → F → F
  deriv : Axis → F → F
  integral : F → Int
  boundary : Axis → F → Int
  derivative_product : ∀ i f g,
    deriv i (mulField f g) =
      addField (mulField (deriv i f) g) (mulField f (deriv i g))
  integral_add : ∀ f g,
    integral (addField f g) = integral f + integral g
  boundary_stokes : ∀ i f,
    integral (deriv i f) = boundary i f

theorem weighted_boundary_integration_by_parts
    {F : Type} (s : BoundarySlice F)
    (i : Axis) (N J : F) :
    s.integral (s.mulField N (s.deriv i J)) +
    s.integral (s.mulField (s.deriv i N) J) =
      s.boundary i (s.mulField N J) := by
  have h := s.boundary_stokes i (s.mulField N J)
  rw [s.derivative_product, s.integral_add] at h
  omega

def volumeTerm {F : Type} (s : BoundarySlice F)
    (N : F) (J : Axis → F) : Int :=
  s.integral (s.mulField N (s.deriv 0 (J 0))) +
  s.integral (s.mulField N (s.deriv 1 (J 1))) +
  s.integral (s.mulField N (s.deriv 2 (J 2)))

def bulkGradient {F : Type} (s : BoundarySlice F)
    (N : F) (J : Axis → F) : Int :=
  s.integral (s.mulField (s.deriv 0 N) (J 0)) +
  s.integral (s.mulField (s.deriv 1 N) (J 1)) +
  s.integral (s.mulField (s.deriv 2 N) (J 2))

def fluxBoundary {F : Type} (s : BoundarySlice F)
    (N : F) (J : Axis → F) : Int :=
  s.boundary 0 (s.mulField N (J 0)) +
  s.boundary 1 (s.mulField N (J 1)) +
  s.boundary 2 (s.mulField N (J 2))

theorem three_direction_boundary_suture
    {F : Type} (s : BoundarySlice F)
    (N : F) (J : Axis → F) :
    volumeTerm s N J =
      fluxBoundary s N J - bulkGradient s N J := by
  have h0 := weighted_boundary_integration_by_parts s 0 N (J 0)
  have h1 := weighted_boundary_integration_by_parts s 1 N (J 1)
  have h2 := weighted_boundary_integration_by_parts s 2 N (J 2)
  simp only [volumeTerm, fluxBoundary, bulkGradient]
  omega

theorem zero_flux_boundary_suture
    {F : Type} (s : BoundarySlice F)
    (N : F) (J : Axis → F)
    (hZero : fluxBoundary s N J = 0) :
    volumeTerm s N J = -bulkGradient s N J := by
  rw [three_direction_boundary_suture, hZero]
  omega

/-! ## Explicit Palatini current -/

abbrev Connection := ConnectionPalatini010h.Connection
def sum3 (f : Axis → Int) : Int := f 0 + f 1 + f 2

def palatiniCurrent (B : Mat3) (V : Connection) (k : Axis) : Int :=
  sum3 (fun l => sum3 (fun j => B l j * V k j l)) -
  sum3 (fun l => sum3 (fun j => B l k * V j j l))

def addConnection (V W : Connection) : Connection :=
  fun k i j => V k i j + W k i j

theorem palatini_current_additive
    (B : Mat3) (V W : Connection) (k : Axis) :
    palatiniCurrent B (addConnection V W) k =
      palatiniCurrent B V k + palatiniCurrent B W k := by
  simp only [palatiniCurrent, sum3, addConnection, Int.mul_add]
  omega

def flatInverse : Mat3 := M1
def sampleVariation : Connection :=
  fun k i j => if k = 0 ∧ i = 1 ∧ j = 1 then 1 else 0

theorem nonzero_palatini_current :
    palatiniCurrent flatInverse sampleVariation 0 = 1 := by decide

/-! ## Concrete nonzero boundary witness -/

open JetStokes010e

def integralJet (f : Jet3) : Int := f.c + f.x + f.y + f.z

def boundaryJet (i : Axis) (f : Jet3) : Int :=
  if i.val = 0 then f.x else if i.val = 1 then f.y else f.z

private theorem axis_cases :
    ∀ i : Axis, i=0 ∨ i=1 ∨ i=2 := by decide

theorem integralJet_add (f g : Jet3) :
    integralJet (JetStokes010e.add f g) =
      integralJet f + integralJet g := by
  simp [integralJet, JetStokes010e.add]
  omega

theorem jet_boundary_stokes (i : Axis) (f : Jet3) :
    integralJet (JetStokes010e.D i f) = boundaryJet i f := by
  rcases axis_cases i with hi | hi | hi <;>
    subst i <;> rfl

def jetBoundarySlice : BoundarySlice Jet3 :=
  { addField := JetStokes010e.add
    mulField := JetStokes010e.mul
    deriv := JetStokes010e.D
    integral := integralJet
    boundary := boundaryJet
    derivative_product := JetStokes010e.D_mul
    integral_add := integralJet_add
    boundary_stokes := jet_boundary_stokes }

def testCurrent : Axis → Jet3 :=
  fun i => if i=0 then JetStokes010e.epsX else JetStokes010e.zero

theorem boundary_flux_nonzero_witness :
    fluxBoundary jetBoundarySlice JetStokes010e.one testCurrent = 1 ∧
    volumeTerm jetBoundarySlice JetStokes010e.one testCurrent = 1 ∧
    bulkGradient jetBoundarySlice JetStokes010e.one testCurrent = 0 := by
  decide

theorem nonzero_boundary_is_load_bearing :
    volumeTerm jetBoundarySlice JetStokes010e.one testCurrent ≠
      -bulkGradient jetBoundarySlice JetStokes010e.one testCurrent := by
  decide

#print axioms weighted_boundary_integration_by_parts
#print axioms three_direction_boundary_suture
#print axioms zero_flux_boundary_suture
#print axioms palatini_current_additive
#print axioms nonzero_palatini_current
#print axioms jet_boundary_stokes
#print axioms boundary_flux_nonzero_witness
#print axioms nonzero_boundary_is_load_bearing

end PalatiniBoundary010i
