import Init.Data.Rat.Basic
import proofs.SutureDirac010a

/-!
# Minimum Mechanics 010b — Maxwell local differential and Gauss bridge

Reference: revised Suture Field Dynamics, SD.23–SD.27.
Depends on certified 010a local Dirac chart, unchanged.

Scope:
1. Polynomial first/second variation of the electric and magnetic quadratic.
2. F=dA, alternating field strength, and vanishing gauge variation of F
   under commuting second spatial derivatives.
3. Exact lapse/gradient cancellation in the local Maxwell normal–normal
   functional Poisson integrand, including finite sums of local cells.
4. Cancellation of the original μ₀/√γ and √γ/μ₀ normalizations.
5. The gauge-improved momentum integrand gives Lie transport of A_i.

The exact *continuum* functional derivatives require an integration-by-parts
lemma on a specified spatial slice and compatible boundary conditions.
Those analytic operations are explained in the companion receipt; they are
NOT supplied by this Lean file. In particular, the full ADM algebra, true
infinite-dimensional Poisson geometry, and gauge first-class theorems on
function spaces are outside this local algebraic certificate.
-/

set_option autoImplicit false

namespace Maxwell010b

/-! ## Quadratic variation before functional integration -/

-- Holds for any two (potentially distinct) tensor slots.
theorem product_variation (a b da db t : Int) :
    (a + t * da) * (b + t * db) =
      a*b + t*(da*b + a*db) + (t*t)*(da*db) := by
  simp only [Int.add_mul, Int.mul_add, Int.mul_assoc]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
  omega

-- The first-order electric variation is twice the symmetric cross
-- contraction. The 1/2 in H_E cancels this 2 at the next step.
theorem symmetric_electric_pair (g a b da db : Int) :
    g*(da*b + a*db) + g*(db*a + b*da) =
      2*g*(da*b + a*db) := by
  have hp : g * (db*a + b*da) = g * (da*b + a*db) := by
    congr 1
    ac_rfl
  rw [hp]
  have ht : (2 : Int) * g = g + g := by omega
  rw [ht, Int.add_mul]

/-! ## F=dA and U(1) Gauss transformation -/

abbrev Axis := Fin 3
abbrev FirstJet := Axis → Axis → Int

def fieldStrength (dA : FirstJet) (i j : Axis) : Int :=
  dA i j - dA j i

theorem field_strength_alternating (dA : FirstJet) (i j : Axis) :
    fieldStrength dA i j = -fieldStrength dA j i := by
  simp only [fieldStrength]
  omega

theorem field_strength_diagonal_zero (dA : FirstJet) (i : Axis) :
    fieldStrength dA i i = 0 := by
  simp [fieldStrength]

-- The Taylor law F(A+t·a)=F(A)+t·F(a) holds for all 3×3 components.
theorem field_strength_variation (dA da : FirstJet) (t : Int)
    (i j : Axis) :
    fieldStrength (fun p q => dA p q + t * da p q) i j =
      fieldStrength dA i j + t * fieldStrength da i j := by
  simp only [fieldStrength]
  rw [Int.mul_sub]
  omega

-- ddα contains the formal Hessian (∂i∂j α), symmetric by the
-- commuting-partials hypothesis. E remains fixed by U(1).
theorem gauss_gauge_invariance (dA ddα : FirstJet)
    (hcomm : ∀ i j, ddα i j = ddα j i) (i j : Axis) :
    fieldStrength (fun p q => dA p q + ddα p q) i j =
      fieldStrength dA i j := by
  simp only [fieldStrength]
  rw [hcomm i j]
  omega

def energyNumerator (electric field : Int)
    (electricScale magneticScale : Int) : Int :=
  electricScale * electric * electric +
    magneticScale * field * field

theorem gauss_preserves_component_energy
    (dA ddα : FirstJet) (hcomm : ∀ i j, ddα i j = ddα j i)
    (electric electricScale magneticScale : Int) (i j : Axis) :
    energyNumerator electric
      (fieldStrength (fun p q => dA p q + ddα p q) i j)
      electricScale magneticScale =
    energyNumerator electric (fieldStrength dA i j)
      electricScale magneticScale := by
  rw [gauss_gauge_invariance dA ddα hcomm i j]

/-! ## Antisymmetry of the magnetic variation -/

theorem magnetic_pair (f dij dji : Int) :
    f * (dij - dji) + (-f) * (dji - dij) =
      2 * f * (dij - dji) := by
  have hp : (-f) * (dji - dij) = f * (dij - dji) := by
    rw [Int.neg_mul, Int.mul_sub]
    omega
  rw [hp]
  have ht : (2 : Int) * f = f + f := by omega
  rw [ht, Int.add_mul]

/-! ## Maxwell normal–normal Poisson integrand -/

-- At one tensor address i,j, write:
--   e_i := μ₀ γ_ik E^k / √γ, K^{ji} := √γ F^{ji}/μ₀.
-- These are the exact derivative coefficients from SD.26, after
-- integration by parts in the A-variation.
def electricResponse (n e : Int) : Int := n * e

def magneticResponse (n dn k dk : Int) : Int :=
  -(dn * k + n * dk)

def localPoisson (n m dn dm e k dk : Int) : Int :=
  magneticResponse n dn k dk * electricResponse m e -
  electricResponse n e * magneticResponse m dm k dk

def localFlux (n m dn dm e k : Int) : Int :=
  (n*dm - m*dn) * (e*k)

-- In particular the NM·∂K pieces cancel without any use of Gauss=0.
theorem maxwell_normal_normal_local
    (n m dn dm e k dk : Int) :
    localPoisson n m dn dm e k dk =
      localFlux n m dn dm e k := by
  simp only [localPoisson, localFlux, electricResponse, magneticResponse]
  simp only [Int.neg_mul, Int.mul_neg, Int.mul_add,
             Int.add_mul, Int.mul_sub, Int.sub_mul, Int.mul_assoc]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
  omega

-- This expresses the algebraic spatial summation with no suppressed cells.
structure Cell where
  n : Int
  m : Int
  dn : Int
  dm : Int
  e : Int
  k : Int
  dk : Int

def cellPoisson (c : Cell) : Int :=
  localPoisson c.n c.m c.dn c.dm c.e c.k c.dk

def cellFlux (c : Cell) : Int :=
  localFlux c.n c.m c.dn c.dm c.e c.k

theorem cell_poisson_equals_flux (c : Cell) :
    cellPoisson c = cellFlux c := by
  exact maxwell_normal_normal_local c.n c.m c.dn c.dm c.e c.k c.dk

theorem maxwell_normal_normal_finite_sum (xs : List Cell) :
    (xs.map cellPoisson).sum = (xs.map cellFlux).sum := by
  induction xs with
  | nil => rfl
  | cons x xs ih =>
      simp only [List.map_cons, List.sum_cons]
      rw [cell_poisson_equals_flux x, ih]

/-! ## Exact Maxwell coefficient normalization -/

def physicalE (μ invRoot ELower : Rat) : Rat :=
  μ * invRoot * ELower

def physicalK (root invμ FUpper : Rat) : Rat :=
  root * invμ * FUpper

theorem maxwell_physical_normalization
    (μ invμ root invRoot ELower FUpper : Rat)
    (hμ : μ * invμ = 1) (hroot : root * invRoot = 1) :
    physicalE μ invRoot ELower * physicalK root invμ FUpper =
      ELower * FUpper := by
  calc
    physicalE μ invRoot ELower * physicalK root invμ FUpper =
        (μ * invμ) * (root * invRoot) * (ELower * FUpper) := by
      simp only [physicalE, physicalK]
      simp only [Rat.mul_assoc, Rat.mul_comm, Rat.mul_left_comm]
    _ = ELower * FUpper := by simp [hμ, hroot]

/-! ## Spatial momentum constraint and Gauss improvement -/

-- Assume ∂j(v^i A_i) is expanded by Leibniz. The first term is the
-- source momentum F_ij E^j, and the second is +A_i G.
-- The result is precisely the Lie derivative of the spatial one-form.
theorem spatial_improvement_gives_lie_one_form
    (v Ai partialI_Aj partialJ_Ai partialJ_v : Int) :
    v * (partialI_Aj - partialJ_Ai) +
      (partialJ_v * Ai + v * partialJ_Ai) =
    v * partialI_Aj + partialJ_v * Ai := by
  rw [Int.mul_sub]
  omega

#print axioms product_variation
#print axioms symmetric_electric_pair
#print axioms field_strength_variation
#print axioms gauss_gauge_invariance
#print axioms gauss_preserves_component_energy
#print axioms magnetic_pair
#print axioms maxwell_normal_normal_local
#print axioms maxwell_normal_normal_finite_sum
#print axioms maxwell_physical_normalization
#print axioms spatial_improvement_gives_lie_one_form

end Maxwell010b
