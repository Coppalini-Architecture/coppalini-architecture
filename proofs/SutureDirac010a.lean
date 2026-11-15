import Init

/-!
# Minimum Mechanics 010a — Suture Dirac chart, algebraic bridge

Source reference: SD.16–SD.20f of revised Suture Field Dynamics.
Predecessor 009 is retained at its declared scope; this file does not import 009.

Office of this file:
* exact 4×4 canonical second-class block and its inverse;
* 16-fold block-diagonal 64-component organization;
* componentwise cotangent-shift identity, including every base coordinate;
* explicit canonical Poisson-jet cancellation for two independent base coordinates;
* Dirac correction vanishes for observables commuting with the eliminated pairs.

Boundary: this is a *local algebraic* chart certificate. It does not prove the
existence of a regular chart from the suture rank theorem, the variational
Einstein–Maxwell field equations, or the ADM hypersurface-deformation algebra.
There are no additional axioms, Mathlib dependencies, or opaque native evaluations.
-/

set_option autoImplicit false

namespace SutureDirac010a

/-! ## Exact SD.20e block -/

-- Order per suture component: (P_q, C=q-X, P_m, m).
def B (i j : Fin 4) : Int :=
  match i.val, j.val with
  | 0, 1 => -1
  | 1, 0 => 1
  | 2, 3 => -1
  | 3, 2 => 1
  | _, _ => 0

def BInv (i j : Fin 4) : Int := -B i j

def mul4 (A D : Fin 4 → Fin 4 → Int) (i j : Fin 4) : Int :=
  A i 0 * D 0 j + A i 1 * D 1 j +
  A i 2 * D 2 j + A i 3 * D 3 j

def delta4 (i j : Fin 4) : Int := if i = j then 1 else 0

def minusDelta4 (i j : Fin 4) : Int := if i = j then -1 else 0

theorem B_square : ∀ i j : Fin 4, mul4 B B i j = minusDelta4 i j := by decide

theorem B_inverse_right : ∀ i j : Fin 4,
    mul4 B BInv i j = delta4 i j := by decide

theorem B_inverse_left : ∀ i j : Fin 4,
    mul4 BInv B i j = delta4 i j := by decide

-- Determinant of the two decoupled 2×2 canonical subblocks.
def det2 (a b c d : Int) : Int := a*d-b*c

def BDet : Int :=
  det2 (B 0 0) (B 0 1) (B 1 0) (B 1 1) *
  det2 (B 2 2) (B 2 3) (B 3 2) (B 3 3)

theorem B_determinant_one : BDet = 1 := by decide

/-! ## 16 addressed copies = 64 auxiliary constraints -/

abbrev Index64 := Fin 16 × Fin 4

def C64 (i j : Index64) : Int :=
  if i.1 = j.1 then B i.2 j.2 else 0

def C64Inv (i j : Index64) : Int := -C64 i j

theorem C64_off_fiber (i j : Index64) (h : i.1 ≠ j.1) :
    C64 i j = 0 := by simp [C64, h]

theorem C64Inv_off_fiber (i j : Index64) (h : i.1 ≠ j.1) :
    C64Inv i j = 0 := by simp [C64Inv, C64, h]

theorem C64_fiber_right_inverse (fiber : Fin 16) (i j : Fin 4) :
    mul4 (fun a b => C64 (fiber, a) (fiber, b))
      (fun a b => C64Inv (fiber, a) (fiber, b)) i j = delta4 i j := by
  simpa [mul4, C64, C64Inv, BInv] using B_inverse_right i j

theorem C64_fiber_left_inverse (fiber : Fin 16) (i j : Fin 4) :
    mul4 (fun a b => C64Inv (fiber, a) (fiber, b))
      (fun a b => C64 (fiber, a) (fiber, b)) i j = delta4 i j := by
  simpa [mul4, C64, C64Inv, BInv] using B_inverse_left i j

/-! ## Exact cotangent coefficient -/

-- A variation dq^I = dr^I + (∂_a X^I) dx^a induces the full shift
-- p_a -> p_a + Σ_I (∂_a X^I) P_qI.
-- This theorem checks each summand before finite summation.
theorem cotangent_coefficient (p pq dr j dx : Int) :
    p * dx + pq * (dr + j * dx) =
      (p + pq * j) * dx + pq * dr := by
  calc
    p * dx + pq * (dr + j * dx)
        = p * dx + (pq * dr + pq * (j * dx)) := by rw [Int.mul_add]
    _ = (p + pq * j) * dx + pq * dr := by
      rw [Int.add_mul, Int.mul_assoc]
      ac_rfl

theorem cotangent_all_components
    (p pq dr dx : Fin 16 → Int)
    (J : Fin 16 → Fin 4 → Int)
    (a : Fin 4) :
    ∀ i : Fin 16,
       p i * dx i + pq i * (dr i + J i a * dx i) =
         (p i + pq i * J i a) * dx i + pq i * dr i := by
  intro i
  exact cotangent_coefficient (p i) (pq i) (dr i) (J i a) (dx i)


-- Summed cotangent identity: the shift is accumulated across every auxiliary
-- address, rather than merely checked for isolated coefficients.
structure CotTerm where
  pq : Int
  dr : Int
  j : Int

def beforeTerm (dx : Int) (t : CotTerm) : Int :=
  t.pq * (t.dr + t.j * dx)

def shiftTerm (t : CotTerm) : Int := t.pq * t.j

def afterTerm (t : CotTerm) : Int := t.pq * t.dr

theorem cotangent_sum_aux (xs : List CotTerm) (dx : Int) :
    (xs.map (beforeTerm dx)).sum =
    (xs.map shiftTerm).sum * dx + (xs.map afterTerm).sum := by
  induction xs with
  | nil => simp [beforeTerm, shiftTerm, afterTerm]
  | cons x xs ih =>
      simp only [List.map_cons, List.sum_cons]
      rw [ih]
      simp only [beforeTerm, shiftTerm, afterTerm]
      rw [Int.mul_add, Int.add_mul, Int.mul_assoc]
      ac_rfl

theorem cotangent_sum (xs : List CotTerm) (p dx : Int) :
    p * dx + (xs.map (beforeTerm dx)).sum =
      (p + (xs.map shiftTerm).sum) * dx +
        (xs.map afterTerm).sum := by
  rw [cotangent_sum_aux, Int.add_mul]
  ac_rfl

def sixteenTerms (pq dr j : Fin 16 → Int) : List CotTerm :=
  List.ofFn (fun i => ⟨pq i, dr i, j i⟩)

theorem cotangent_16
    (pq dr : Fin 16 → Int) (J : Fin 16 → Fin 4 → Int)
    (a : Fin 4) (p dx : Int) :
    p * dx + ((sixteenTerms pq dr (fun i => J i a)).map (beforeTerm dx)).sum =
      (p + ((sixteenTerms pq dr (fun i => J i a)).map shiftTerm).sum) * dx +
        ((sixteenTerms pq dr (fun i => J i a)).map afterTerm).sum := by
  exact cotangent_sum (sixteenTerms pq dr (fun i => J i a)) p dx

/-! ## The canonical Poisson 1- and 2-jet calculation -/

-- Two base pairs (x_0,p_0), (x_1,p_1), and one auxiliary pair (q,P_q).
-- All coefficients are formal first/second partials of one X at a point.
-- The two-base-coordinate calculation is representative of each index pair.
structure Jet where
  dx0 : Int
  dx1 : Int
  dp0 : Int
  dp1 : Int
  dq  : Int
  dpq : Int
  deriving DecidableEq, Repr

def pb (f g : Jet) : Int :=
  (f.dx0 * g.dp0 - f.dp0 * g.dx0) +
  (f.dx1 * g.dp1 - f.dp1 * g.dx1) +
  (f.dq * g.dpq - f.dpq * g.dq)

-- C := q-X; gradients in the canonical (x,p,q,Pq) variables.
def gradC (j0 j1 : Int) : Jet := ⟨-j0, -j1, 0, 0, 1, 0⟩
def gradPq : Jet := ⟨0, 0, 0, 0, 0, 1⟩
def gradP0 : Jet := ⟨0, 0, 1, 0, 0, 0⟩
def gradP1 : Jet := ⟨0, 0, 0, 1, 0, 0⟩

-- p̃_a = p_a + J_a Pq; mixed Hessian entries enter its x-gradient.
def gradShiftP0 (j0 h00 h10 pq : Int) : Jet :=
  ⟨h00 * pq, h10 * pq, 1, 0, 0, j0⟩
def gradShiftP1 (j1 h01 h11 pq : Int) : Jet :=
  ⟨h01 * pq, h11 * pq, 0, 1, 0, j1⟩

theorem C_Pq_is_canonical (j0 j1 : Int) :
    pb (gradC j0 j1) gradPq = 1 := by
  simp [pb, gradC, gradPq]

theorem unshifted_p0_detects_X (j0 j1 : Int) :
    pb gradP0 (gradC j0 j1) = j0 := by
  simp [pb, gradP0, gradC]

theorem unshifted_p1_detects_X (j0 j1 : Int) :
    pb gradP1 (gradC j0 j1) = j1 := by
  simp [pb, gradP1, gradC]

theorem shifted_p0_commutes_C (j0 j1 h00 h10 pq : Int) :
    pb (gradShiftP0 j0 h00 h10 pq) (gradC j0 j1) = 0 := by
  simp [pb, gradShiftP0, gradC] <;> omega

theorem shifted_p1_commutes_C (j0 j1 h01 h11 pq : Int) :
    pb (gradShiftP1 j1 h01 h11 pq) (gradC j0 j1) = 0 := by
  simp [pb, gradShiftP1, gradC] <;> omega

theorem shifted_p0_commutes_Pq (j0 h00 h10 pq : Int) :
    pb (gradShiftP0 j0 h00 h10 pq) gradPq = 0 := by
  simp [pb, gradShiftP0, gradPq]

theorem shifted_p1_commutes_Pq (j1 h01 h11 pq : Int) :
    pb (gradShiftP1 j1 h01 h11 pq) gradPq = 0 := by
  simp [pb, gradShiftP1, gradPq]

-- Commuting mixed partials: ∂_1 ∂_0 X = ∂_0 ∂_1 X.
theorem shifted_momenta_commute
    (j0 j1 h00 h10 h01 h11 pq : Int) (hmix : h10 = h01) :
    pb (gradShiftP0 j0 h00 h10 pq)
       (gradShiftP1 j1 h01 h11 pq) = 0 := by
  subst h01
  simp [pb, gradShiftP0, gradShiftP1] <;> omega

/-! ## Dirac bracket restriction -/

-- In a canonical (r,Pr,m,Pm) Darboux chart, an exterior observable F
-- satisfies {F,ζ_a}=0. Every component of the Dirac correction then
-- vanishes. Here the per-address expression uses BInv explicitly.
def correction4 (F G : Fin 4 → Int) : Int :=
  F 0 * (BInv 0 0 * G 0 + BInv 0 1 * G 1 +
          BInv 0 2 * G 2 + BInv 0 3 * G 3) +
  F 1 * (BInv 1 0 * G 0 + BInv 1 1 * G 1 +
          BInv 1 2 * G 2 + BInv 1 3 * G 3) +
  F 2 * (BInv 2 0 * G 0 + BInv 2 1 * G 1 +
          BInv 2 2 * G 2 + BInv 2 3 * G 3) +
  F 3 * (BInv 3 0 * G 0 + BInv 3 1 * G 1 +
          BInv 3 2 * G 2 + BInv 3 3 * G 3)

def dirac4 (ordinary : Int) (F G : Fin 4 → Int) : Int :=
  ordinary - correction4 F G

theorem dirac_exterior_lhs (ordinary : Int) (G : Fin 4 → Int) :
    dirac4 ordinary (fun _ => 0) G = ordinary := by
  simp [dirac4, correction4]

theorem dirac_exterior_rhs (ordinary : Int) (F : Fin 4 → Int) :
    dirac4 ordinary F (fun _ => 0) = ordinary := by
  simp [dirac4, correction4]

#print axioms B_square
#print axioms B_inverse_right
#print axioms B_inverse_left
#print axioms B_determinant_one
#print axioms C64_fiber_right_inverse
#print axioms C64_fiber_left_inverse
#print axioms cotangent_coefficient
#print axioms cotangent_sum
#print axioms cotangent_16
#print axioms shifted_p0_commutes_C
#print axioms shifted_p1_commutes_C
#print axioms shifted_momenta_commute
#print axioms dirac_exterior_lhs
#print axioms dirac_exterior_rhs

end SutureDirac010a
