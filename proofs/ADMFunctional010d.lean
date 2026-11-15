import Init.Data.Rat.Basic
import proofs.ADMGravity010c

/-!
# Minimum Mechanics 010d — Stokes / functional ADM bracket interface

Fixed sources:
* Suture Field Dynamics (revised), SD.22–SD.27.
* 010a local suture Dirac chart (imported through 010b and 010c).
* 010b Maxwell normal-normal integrand and finite summation.
* 010c gravitational DeWitt/Hessian contraction and negative control.

Certified here:
* Single and double integration by parts from a separately declared
  Stokes property, Leibniz rule, and additive integral.
* Explicit 3D symmetric-density current and gravitational jet identity.
* Integrating the current identity under a boundary-divergence witness.
* Combining that gravitational reduction with inherited Maxwell cancellation.

The Stokes input is a hypothesis on an abstract commutative function algebra.
The finite cell identity is the exact local covariant jet algebra, NOT a
discretization theorem for smooth geometry. The witness "boundary_flux_zero"
is NOT asserted automatically. The identification of those cells/operations
with the geometric Einstein-Hilbert first variation (Palatini identity) is a
separate OPEN obligation. Thus this is a conditional functional bridge,
not an unconditional full Dirac-ADM first-class theorem.
-/

set_option autoImplicit false

namespace ADMFunctional010d

/-! ## Stokes -> IBP, without assuming IBP itself -/

-- A represents a ring of admissible smooth scalar fields on the slice.
-- Concrete instances must supply derivative, integrated density, and boundary
-- properties; the structure makes the analytic requirements inspectable.
structure StokesSlice (A : Type) [CommRing A] where
  deriv : Fin 3 → A → A
  integral : A → A
  derivative_product : ∀ i f g, deriv i (f*g) =
    (deriv i f)*g + f*(deriv i g)
  integral_add : ∀ f g, integral (f+g) = integral f + integral g
  stokes_zero : ∀ i f, integral (deriv i f) = 0

theorem first_integration_by_parts {A : Type} [CommRing A]
    (s : StokesSlice A) (i : Fin 3) (f g : A) :
    s.integral (f * s.deriv i g) =
      -s.integral ((s.deriv i f) * g) := by
  have hs := s.stokes_zero i (f*g)
  rw [s.derivative_product, s.integral_add] at hs
  have hswap :
      s.integral (f * s.deriv i g) +
      s.integral ((s.deriv i f) * g) = 0 := by
    simpa only [add_comm] using hs
  exact (eq_neg_iff_add_eq_zero).2 hswap

theorem second_integration_by_parts {A : Type} [CommRing A]
    (s : StokesSlice A) (i j : Fin 3) (f h : A) :
    s.integral (f * s.deriv i (s.deriv j h)) =
      s.integral ((s.deriv j (s.deriv i f)) * h) := by
  rw [first_integration_by_parts s i f (s.deriv j h)]
  rw [first_integration_by_parts s j (s.deriv i f) h]
  simp

-- If the scalar covariant derivatives commute, Hessian order returns.
theorem second_ibp_commuting_scalar {A : Type} [CommRing A]
    (s : StokesSlice A) (i j : Fin 3) (f h : A)
    (hcomm : s.deriv j (s.deriv i f) = s.deriv i (s.deriv j f)) :
    s.integral (f * s.deriv i (s.deriv j h)) =
      s.integral ((s.deriv i (s.deriv j f)) * h) := by
  rw [second_integration_by_parts s i j f h, hcomm]

/-! ## Local ADM current from exact 010c tensor carriers -/

open ADMGravity010c

def dotVector3 (u v : Vec3) : Int :=
  u.x*v.x + u.y*v.y + u.z*v.z

def currentCov (N M : Int) (dN dM : Vec3) : Vec3 :=
  ⟨N*dM.x - M*dN.x,
   N*dM.y - M*dN.y,
   N*dM.z - M*dN.z⟩

-- The entries of divPi are covariant divergences D_i π^{ij}
-- of a contravariant momentum density of weight +1.
structure NormalCell where
  N : Int
  M : Int
  dN : Vec3
  dM : Vec3
  hN : Sym3
  hM : Sym3
  pi : Sym3
  divPi : Vec3

def wedge (c : NormalCell) : Int :=
  bilinear3 c.pi c.dN c.dM - bilinear3 c.pi c.dM c.dN

def scalarHessianBracket (c : NormalCell) : Int :=
  2 * (c.N * dot3 c.pi c.hM - c.M * dot3 c.pi c.hN)

def gravMomentumSmear (c : NormalCell) : Int :=
  -2 * dotVector3 c.divPi (currentCov c.N c.M c.dN c.dM)

-- The product rule for the vector-density current
--   J^i = 2 π^{ij} (N D_j M - M D_j N).
-- In a metric-compatible orthonormal frame, its formal divergence is:
--   2 (D_i π^{ij}) w_j + 2 π^{ij}(D_i N D_j M - D_i M D_j N)
--      + 2 π^{ij}(N D_iD_j M - M D_iD_j N).
-- The prior 010c slot-wise Leibniz identity supplies that product expansion.
def gravCurrentDivergence (c : NormalCell) : Int :=
  2 * (dotVector3 c.divPi (currentCov c.N c.M c.dN c.dM) +
    wedge c +
    (c.N * dot3 c.pi c.hM - c.M * dot3 c.pi c.hN))

theorem symmetric_current_wedge_zero (c : NormalCell) :
    wedge c = 0 := by
  exact symmetric_gradient_wedge_zero c.pi c.dN c.dM

theorem gravitational_divergence_identity (c : NormalCell) :
    scalarHessianBracket c =
      gravCurrentDivergence c + gravMomentumSmear c := by
  have hw := symmetric_current_wedge_zero c
  simp only [scalarHessianBracket, gravCurrentDivergence,
    gravMomentumSmear, hw, add_zero]
  omega

/-! ## From pointwise currents to an integrated normal-normal bracket -/

def sumCells (xs : List NormalCell) (f : NormalCell → Int) : Int :=
  (xs.map f).sum

theorem sum_gravitational_divergence_identity (xs : List NormalCell) :
    sumCells xs scalarHessianBracket =
      sumCells xs gravCurrentDivergence +
        sumCells xs gravMomentumSmear := by
  induction xs with
  | nil =>
      simp [sumCells]
  | cons c cs ih =>
      simp only [sumCells, List.map_cons, List.sum_cons] at ih ⊢
      rw [gravitational_divergence_identity c]
      omega

-- Exact statement under the separately witnessed vanishing boundary flux.
-- The premise is the integrated Stokes condition, which must be provided
-- by a smooth closed slice or appropriate boundary/falloff assumptions.
theorem gravity_normal_normal_from_boundary
    (xs : List NormalCell)
    (boundary_flux_zero : sumCells xs gravCurrentDivergence = 0) :
    sumCells xs scalarHessianBracket =
      sumCells xs gravMomentumSmear := by
  rw [sum_gravitational_divergence_identity xs, boundary_flux_zero]
  omega

/-! ## Combine with the inherited Maxwell exact bracket -/

def maxwellBracket (xs : List Maxwell010b.Cell) : Int :=
  (xs.map Maxwell010b.cellPoisson).sum

def maxwellMomentum (xs : List Maxwell010b.Cell) : Int :=
  (xs.map Maxwell010b.cellFlux).sum

theorem maxwell_bracket_equals_momentum (xs : List Maxwell010b.Cell) :
    maxwellBracket xs = maxwellMomentum xs :=
  Maxwell010b.maxwell_normal_normal_finite_sum xs

def combinedNormalBracket
    (g : List NormalCell) (e : List Maxwell010b.Cell) : Int :=
  sumCells g scalarHessianBracket + maxwellBracket e

def combinedMomentum
    (g : List NormalCell) (e : List Maxwell010b.Cell) : Int :=
  sumCells g gravMomentumSmear + maxwellMomentum e

theorem einstein_maxwell_normal_normal_conditional
    (g : List NormalCell) (e : List Maxwell010b.Cell)
    (boundary_flux_zero : sumCells g gravCurrentDivergence = 0) :
    combinedNormalBracket g e = combinedMomentum g e := by
  simp only [combinedNormalBracket, combinedMomentum]
  rw [gravity_normal_normal_from_boundary g boundary_flux_zero,
      maxwell_bracket_equals_momentum e]

/-! ## Gauss-improved momentum is a compatible second presentation -/

def improvedDiffeomorphism (momentum gaussContribution : Int) : Int :=
  momentum + gaussContribution

theorem unimproved_equals_improved_minus_gauss
    (momentum gaussContribution : Int) :
    momentum =
      improvedDiffeomorphism momentum gaussContribution -
        gaussContribution := by
  simp [improvedDiffeomorphism]

theorem normal_normal_improved_gauge_presentation
    (g : List NormalCell) (e : List Maxwell010b.Cell)
    (gaussContribution : Int)
    (boundary_flux_zero : sumCells g gravCurrentDivergence = 0) :
    combinedNormalBracket g e =
      improvedDiffeomorphism (combinedMomentum g e) gaussContribution -
        gaussContribution := by
  rw [einstein_maxwell_normal_normal_conditional g e boundary_flux_zero]
  exact unimproved_equals_improved_minus_gauss
    (combinedMomentum g e) gaussContribution

#print axioms first_integration_by_parts
#print axioms second_integration_by_parts
#print axioms second_ibp_commuting_scalar
#print axioms gravitational_divergence_identity
#print axioms sum_gravitational_divergence_identity
#print axioms gravity_normal_normal_from_boundary
#print axioms maxwell_bracket_equals_momentum
#print axioms einstein_maxwell_normal_normal_conditional
#print axioms normal_normal_improved_gauge_presentation

end ADMFunctional010d
