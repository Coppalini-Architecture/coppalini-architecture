import Init.Data.Rat.Basic
import proofs.FlatEHFunctional010h

/-!
# Minimum Mechanics 010i — exact 3×3 inverse-metric differential

FIXED: 010a–010h source references and certified claims remain unchanged.
THIS CERTIFICATE: the unique first-order inverse response for an arbitrary
invertible 3×3 matrix, proved from the explicit matrix product and its unit.
Given gB=Bg=I, define dB = -B h B. Then
   h B + g dB = 0,     dB g + B h = 0.
These are exact first-order conditions for (g + εh)(B + εdB)=I
and (B + εdB)(g + εh)=I in the ring ε²=0.

This matrix algebra does not assert the geometric existence of a positive
smooth Riemannian metric, nor an analytic derivative of its inverse in a
function-space topology. The inverse and its first variation are certifiable
pointwise operations. No scalar curvature or ADM constraint closure is claimed.

Lean 4.33.0 · no Mathlib · no sorry · no new axioms.
-/
set_option autoImplicit false
namespace MetricInverse010i

abbrev Axis := Fin 3
abbrev Mat3 := Axis → Axis → Int

def M0 : Mat3 := fun _ _ => 0
def M1 : Mat3 := fun i j => if i = j then 1 else 0
def add (A B : Mat3) : Mat3 := fun i j => A i j + B i j
def neg (A : Mat3) : Mat3 := fun i j => -(A i j)
def mul (A B : Mat3) : Mat3 :=
  fun i j => A i 0 * B 0 j + A i 1 * B 1 j + A i 2 * B 2 j

theorem add_comm (A B : Mat3) : add A B = add B A := by
  funext i j
  simp only [add]
  omega

theorem add_neg (A : Mat3) : add A (neg A) = M0 := by
  funext i j
  simp only [add, neg, M0]
  omega

theorem mul_add (A B C : Mat3) : mul A (add B C) =
    add (mul A B) (mul A C) := by
  funext i j
  simp only [mul, add, Int.mul_add]
  omega

theorem add_mul (A B C : Mat3) : mul (add A B) C =
    add (mul A C) (mul B C) := by
  funext i j
  simp only [mul, add, Int.add_mul]
  omega

theorem mul_neg (A B : Mat3) : mul A (neg B) =
    neg (mul A B) := by
  funext i j
  simp only [mul, neg, Int.mul_neg]
  omega

theorem neg_mul (A B : Mat3) : mul (neg A) B =
    neg (mul A B) := by
  funext i j
  simp only [mul, neg, Int.neg_mul]
  omega

theorem mul_assoc (A B C : Mat3) :
    mul (mul A B) C = mul A (mul B C) := by
  funext i j
  simp only [mul, Int.mul_add, Int.add_mul, Int.mul_assoc]
  ac_rfl

private theorem axis_cases : ∀ k : Axis,
    k = 0 ∨ k = 1 ∨ k = 2 := by decide

theorem mul_one (A : Mat3) : mul A M1 = A := by
  funext i j
  rcases axis_cases j with hj | hj | hj <;>
    subst j <;> simp [mul, M1]

theorem one_mul (A : Mat3) : mul M1 A = A := by
  funext i j
  rcases axis_cases i with hi | hi | hi <;>
    subst i <;> simp [mul, M1]

def dInverse (B h : Mat3) : Mat3 :=
  neg (mul B (mul h B))

theorem right_inverse_differential
    (g B h : Mat3) (hRight : mul g B = M1) :
    add (mul h B) (mul g (dInverse B h)) = M0 := by
  calc
    add (mul h B) (mul g (dInverse B h)) =
      add (mul h B) (neg (mul (mul g B) (mul h B))) := by
        simp only [dInverse, mul_neg, ← mul_assoc]
    _ = add (mul h B) (neg (mul M1 (mul h B))) := by rw [hRight]
    _ = M0 := by rw [one_mul, add_neg]

theorem left_inverse_differential
    (g B h : Mat3) (hLeft : mul B g = M1) :
    add (mul (dInverse B h) g) (mul B h) = M0 := by
  calc
    add (mul (dInverse B h) g) (mul B h) =
      add (neg (mul B (mul h (mul B g)))) (mul B h) := by
        simp only [dInverse, neg_mul, mul_assoc]
    _ = add (neg (mul B (mul h M1))) (mul B h) := by rw [hLeft]
    _ = M0 := by
      rw [mul_one]
      rw [add_comm, add_neg]

theorem inverse_response_unique
    (g B h X : Mat3)
    (hLeft : mul B g = M1)
    (hFirst : add (mul h B) (mul g X) = M0) :
    X = dInverse B h := by
  -- Multiply h B + g X = 0 on the left by B, then use Bg=I.
  have hB : mul B (mul h B) = neg X := by
    have hx := congrArg (mul B) hFirst
    rw [mul_add, ← mul_assoc, hLeft, one_mul] at hx
    have hZero : mul B M0 = M0 := by
      funext i j
      simp [mul, M0]
    rw [hZero] at hx
    funext i j
    have hval := congrFun (congrFun hx i) j
    simp [add, M0] at hval
    omega
  funext i j
  have hval := congrFun (congrFun hB i) j
  simp [dInverse, neg] at *
  omega

-- The second-order discrepancy is the exact product of two first
-- variations; ε²=0 eliminates it without a truncation approximation.
def secondOrderResidual (h B : Mat3) : Mat3 :=
  mul h (dInverse B h)

theorem formal_first_order_product
    (g B h : Mat3) (hRight : mul g B = M1) :
    add (mul g B) (add (mul h B) (mul g (dInverse B h))) = M1 := by
  rw [right_inverse_differential g B h hRight, hRight]
  simp [add, M0]

#print axioms mul_assoc
#print axioms mul_one
#print axioms one_mul
#print axioms right_inverse_differential
#print axioms left_inverse_differential
#print axioms inverse_response_unique
#print axioms formal_first_order_product
end MetricInverse010i
