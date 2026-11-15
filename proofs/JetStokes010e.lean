import Init.Data.Rat.Basic
import proofs.ADMFunctional010d

/-!
# Minimum Mechanics 010e — concrete three-direction Stokes model and U(1) action

Predecessor: certified 010a–010d (unchanged).

The concrete model is the commutative first-order jet algebra
  A = ℤ[ε₀,ε₁,ε₂] / (εᵢεⱼ = 0 for all i,j).
An element is c + x ε₀ + y ε₁ + z ε₂. Its three Euler derivatives
  Dᵢ(c + ∑ⱼ aⱼεⱼ) = aᵢ εᵢ
are NONZERO derivations and commute. The constant-coefficient functional
  I(f) = c
obeys I(Dᵢf)=0. We instantiate the exact abstract StokesSlice contract of
010d with this nontrivial differential algebra.

We also prove the exact abelian gauge action on three potential components
Aᵢ -> Aᵢ + Dᵢ α, the invariance of Fᵢⱼ = DᵢAⱼ-DⱼAᵢ,
and the Gauss action's commutativity.

JURISDICTION: this is a finite first-jet differential model and an explicit
algebraic Stokes instance. It is not a C∞(T³) construction, a nondegenerate
continuum spatial integration, or a proof of Einstein-Hilbert functional
variation. Those remain OPEN. In particular the full Dirac–ADM first-class
algebra is NOT claimed by this file.
-/

set_option autoImplicit false

namespace JetStokes010e

structure Jet3 where
  c : Int
  x : Int
  y : Int
  z : Int
  deriving DecidableEq, Repr

def zero : Jet3 := ⟨0,0,0,0⟩
def one : Jet3 := ⟨1,0,0,0⟩
def epsX : Jet3 := ⟨0,1,0,0⟩
def epsY : Jet3 := ⟨0,0,1,0⟩
def epsZ : Jet3 := ⟨0,0,0,1⟩

def add (a b : Jet3) : Jet3 :=
  ⟨a.c+b.c, a.x+b.x, a.y+b.y, a.z+b.z⟩

def neg (a : Jet3) : Jet3 :=
  ⟨-a.c, -a.x, -a.y, -a.z⟩

def mul (a b : Jet3) : Jet3 :=
  ⟨a.c*b.c,
   a.c*b.x + a.x*b.c,
   a.c*b.y + a.y*b.c,
   a.c*b.z + a.z*b.c⟩

-- This algebra is genuinely nonzero but all products εᵢεⱼ vanish.
theorem epsX_squared : mul epsX epsX = zero := by decide
theorem epsX_epsY : mul epsX epsY = zero := by decide
theorem one_times_epsX : mul one epsX = epsX := by decide

theorem add_comm (a b : Jet3) : add a b = add b a := by
  cases a with
  | mk ac ax ay az =>
    cases b with
    | mk bc bx bY bz =>
      simp only [add, Jet3.mk.injEq]
      omega

theorem add_assoc (a b c : Jet3) :
    add (add a b) c = add a (add b c) := by
  cases a with
  | mk ac ax ay az =>
    cases b with
    | mk bc bx bY bz =>
      cases c with
      | mk cc cx cy cz =>
        simp only [add, Jet3.mk.injEq]
        omega

theorem add_zero (a : Jet3) : add a zero = a := by
  cases a with
  | mk ac ax ay az => simp [add, zero]

theorem add_neg (a : Jet3) : add a (neg a) = zero := by
  cases a with
  | mk ac ax ay az => simp [add, neg, zero, Int.add_neg_self]

theorem neg_neg (a : Jet3) : neg (neg a) = a := by
  cases a with
  | mk ac ax ay az => simp [neg]

theorem mul_comm (a b : Jet3) : mul a b = mul b a := by
  cases a with
  | mk ac ax ay az =>
    cases b with
    | mk bc bx bY bz =>
      simp only [mul, Jet3.mk.injEq]
      constructor
      · exact Int.mul_comm ac bc
      constructor
      · rw [Int.mul_comm ac bx, Int.mul_comm ax bc]
        omega
      constructor
      · rw [Int.mul_comm ac bY, Int.mul_comm ay bc]
        omega
      · rw [Int.mul_comm ac bz, Int.mul_comm az bc]
        omega

def D (i : Fin 3) (a : Jet3) : Jet3 :=
  if i.val = 0 then ⟨0,a.x,0,0⟩
  else if i.val = 1 then ⟨0,0,a.y,0⟩
  else ⟨0,0,0,a.z⟩

private theorem fin3_address (i : Fin 3) :
    i.val = 0 ∨ i.val = 1 ∨ i.val = 2 := by omega

theorem D_add (i : Fin 3) (a b : Jet3) :
    D i (add a b) = add (D i a) (D i b) := by
  have h := fin3_address i
  cases h with
  | inl h0 =>
      simp [D, h0, add]
  | inr h =>
      cases h with
      | inl h1 =>
          have h0 : i.val ≠ 0 := by omega
          simp [D, h0, h1, add]
      | inr h2 =>
          have h0 : i.val ≠ 0 := by omega
          have h1 : i.val ≠ 1 := by omega
          simp [D, h0, h1, add]

theorem D_mul (i : Fin 3) (a b : Jet3) :
    D i (mul a b) = add (mul (D i a) b) (mul a (D i b)) := by
  have h := fin3_address i
  cases h with
  | inl h0 =>
      simp only [D, h0, ↓reduceIte, mul, add, Jet3.mk.injEq]
      omega
  | inr h =>
      cases h with
      | inl h1 =>
          have h0 : i.val ≠ 0 := by omega
          simp [D, h0, h1, mul, add, Jet3.mk.injEq] <;> omega
      | inr h2 =>
          have h0 : i.val ≠ 0 := by omega
          have h1 : i.val ≠ 1 := by omega
          simp only [D, h0, h1, ↓reduceIte, mul, add, Jet3.mk.injEq]
          omega

theorem D_commutes (i j : Fin 3) (a : Jet3) :
    D i (D j a) = D j (D i a) := by
  have hi := fin3_address i
  have hj := fin3_address j
  cases hi with
  | inl hi0 =>
      cases hj with
      | inl hj0 => simp [D, hi0, hj0]
      | inr hj =>
        cases hj with
        | inl hj1 =>
            have hj0 : j.val ≠ 0 := by omega
            simp [D, hi0, hj0, hj1]
        | inr hj2 =>
            have hj0 : j.val ≠ 0 := by omega
            have hj1 : j.val ≠ 1 := by omega
            simp [D, hi0, hj0, hj1]
  | inr hi =>
    cases hi with
    | inl hi1 =>
      have hi0 : i.val ≠ 0 := by omega
      cases hj with
      | inl hj0 => simp [D, hi0, hi1, hj0]
      | inr hj =>
        cases hj with
        | inl hj1 =>
            have hj0 : j.val ≠ 0 := by omega
            simp [D, hi0, hi1, hj0, hj1]
        | inr hj2 =>
            have hj0 : j.val ≠ 0 := by omega
            have hj1 : j.val ≠ 1 := by omega
            simp [D, hi0, hi1, hj0, hj1]
    | inr hi2 =>
      have hi0 : i.val ≠ 0 := by omega
      have hi1 : i.val ≠ 1 := by omega
      cases hj with
      | inl hj0 => simp [D, hi0, hi1, hj0]
      | inr hj =>
        cases hj with
        | inl hj1 =>
            have hj0 : j.val ≠ 0 := by omega
            simp [D, hi0, hi1, hj0, hj1]
        | inr hj2 =>
            have hj0 : j.val ≠ 0 := by omega
            have hj1 : j.val ≠ 1 := by omega
            simp [D, hi0, hi1, hj0, hj1]

def I (a : Jet3) : Int := a.c

theorem I_add (a b : Jet3) :
    I (add a b) = I a + I b := rfl

theorem stokes (i : Fin 3) (a : Jet3) : I (D i a) = 0 := by
  have h := fin3_address i
  cases h with
  | inl h0 => simp [I, D, h0]
  | inr h =>
      cases h with
      | inl h1 =>
          have h0 : i.val ≠ 0 := by omega
          simp [I, D, h0, h1]
      | inr h2 =>
          have h0 : i.val ≠ 0 := by omega
          have h1 : i.val ≠ 1 := by omega
          simp [I, D, h0, h1]

def slice : ADMFunctional010d.StokesSlice Jet3 Int :=
  { addField := add
    mulField := mul
    multiply_comm := mul_comm
    deriv := D
    integral := I
    zeroScalar := 0
    addScalar := (· + ·)
    negScalar := Neg.neg
    derivative_product := D_mul
    integral_add := I_add
    stokes_zero := stokes
    sum_comm := Int.add_comm
    sum_zero_to_neg := by
      intro x y h
      omega
    double_neg := by
      intro x
      omega }

-- These are explicit instances of the previously certified
-- 010d theorems, now with a nontrivial carrier rather than a postulate.
theorem concrete_first_ibp (i : Fin 3) (f g : Jet3) :
    I (mul f (D i g)) = -(I (mul (D i f) g)) :=
  ADMFunctional010d.first_integration_by_parts slice i f g

theorem concrete_second_ibp (i j : Fin 3) (f g : Jet3) :
    I (mul f (D i (D j g))) = I (mul (D j (D i f)) g) :=
  ADMFunctional010d.second_integration_by_parts slice i j f g

theorem concrete_palatini_transfer (i j : Fin 3) (n h : Jet3) :
    I (mul n (D i (D j h))) = I (mul h (D j (D i n))) :=
  ADMFunctional010d.palatini_mixed_second_transfer slice i j n h

theorem nonzero_derivative : D 0 epsX = epsX := by decide
theorem nonzero_derivative_witness : D 0 epsX ≠ zero := by decide
theorem integrated_derivative_zero : I (D 0 epsX) = 0 := by decide
theorem negative_control_wrong_integral :
    I epsX = 0 ∧ I one = 1 := by decide

/-! ## Explicit commuting U(1) gauge transformations -/

abbrev Potential := Fin 3 → Jet3

def gauge (A : Potential) (α : Jet3) : Potential :=
  fun i => add (A i) (D i α)

def flux (A : Potential) (i j : Fin 3) : Jet3 :=
  add (D i (A j)) (neg (D j (A i)))

theorem neg_add (a b : Jet3) :
    neg (add a b) = add (neg a) (neg b) := by
  cases a with
  | mk ac ax ay az =>
    cases b with
    | mk bc bx bY bz =>
      simp only [neg, add, Jet3.mk.injEq]
      omega

theorem flux_add (A B : Potential) (i j : Fin 3) :
    flux (fun k => add (A k) (B k)) i j =
      add (flux A i j) (flux B i j) := by
  simp only [flux, D_add, neg_add]
  -- This is commutativity and associativity of the four additive terms.
  -- Unfolding the four Jet3 slots reduces the calculation to Int addition.
  simp only [add, neg, Jet3.mk.injEq]
  omega

theorem flux_gauge_invariant (A : Potential) (α : Jet3) (i j : Fin 3) :
    flux (gauge A α) i j = flux A i j := by
  simp only [flux, gauge, D_add]
  rw [D_commutes i j α]
  simp only [add, neg, Jet3.mk.injEq]
  omega

theorem gauss_commutator_zero (A : Potential) (α β : Jet3) :
    gauge (gauge A α) β = gauge (gauge A β) α := by
  funext i
  simp only [gauge]
  rw [add_assoc, add_comm (D i α) (D i β), ← add_assoc]
  
#print axioms D_mul
#print axioms D_commutes
#print axioms stokes
#print axioms concrete_first_ibp
#print axioms concrete_second_ibp
#print axioms concrete_palatini_transfer
#print axioms nonzero_derivative_witness
#print axioms flux_gauge_invariant
#print axioms gauss_commutator_zero

end JetStokes010e
