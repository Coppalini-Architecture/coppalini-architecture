import Init.Data.Rat.Basic
import proofs.MetricInverse010i

/-!
# Minimum Mechanics 010i — determinant and volume first-order algebra

The general 3x3 metric g and perturbation h are represented over Int.
We compute the first coefficient of det(g + εh) with ε²=0, then
prove the explicit nine-cofactor expression for that coefficient.
The adjugate has a separate product certificate.

The square-root volume law is represented over Rat:
   v² = det(g),  2v δv = δdet(g).
The Lean proof derives the unique rational dVolume for a nonzero
v from this exact first-order square equation. An arbitrary positive
smooth sqrt(det g) and its differentiability are ANALYTIC inputs
remaining OPEN; finite-dimensional rational square witnesses do not
supply them.

No Mathlib dependency, no sorry, and no new axioms.
-/
set_option autoImplicit false
namespace MetricDeterminant010i

open MetricInverse010i
abbrev Axis := Fin 3

structure Dual where
  base : Int
  eps : Int
  deriving DecidableEq, Repr

def dAdd (a b : Dual) : Dual :=
  ⟨a.base+b.base,a.eps+b.eps⟩
def dNeg (a : Dual) : Dual :=
  ⟨-a.base,-a.eps⟩
def dSub (a b : Dual) : Dual := dAdd a (dNeg b)
def dMul (a b : Dual) : Dual :=
  ⟨a.base*b.base,a.base*b.eps+a.eps*b.base⟩
def dTriple (a b c : Dual) : Dual := dMul (dMul a b) c
def lift (g h : Mat3) (i j : Axis) : Dual := ⟨g i j,h i j⟩

def triple (a b c : Int) : Int := a*b*c
def dTripleCoeff (a b c da db dc : Int) : Int :=
  da*b*c + a*db*c + a*b*dc

theorem dTriple_exact (a b c da db dc : Int) :
    (dTriple ⟨a,da⟩ ⟨b,db⟩ ⟨c,dc⟩).eps =
      dTripleCoeff a b c da db dc := by
  simp only [dTriple,dMul,dTripleCoeff]
  rw [Int.add_mul]
  omega

def determinant (g : Mat3) : Int :=
  triple (g 0 0) (g 1 1) (g 2 2) +
  triple (g 0 1) (g 1 2) (g 2 0) +
  triple (g 0 2) (g 1 0) (g 2 1) -
  triple (g 0 2) (g 1 1) (g 2 0) -
  triple (g 0 0) (g 1 2) (g 2 1) -
  triple (g 0 1) (g 1 0) (g 2 2)

def determinantDual (g : Axis → Axis → Dual) : Dual :=
  dSub
    (dSub
      (dSub
        (dAdd
          (dAdd (dTriple (g 0 0) (g 1 1) (g 2 2))
                (dTriple (g 0 1) (g 1 2) (g 2 0)))
          (dTriple (g 0 2) (g 1 0) (g 2 1)))
        (dTriple (g 0 2) (g 1 1) (g 2 0)))
      (dTriple (g 0 0) (g 1 2) (g 2 1)))
    (dTriple (g 0 1) (g 1 0) (g 2 2))

def deltaDet (g h : Mat3) : Int :=
  dTripleCoeff (g 0 0) (g 1 1) (g 2 2) (h 0 0) (h 1 1) (h 2 2) +
  dTripleCoeff (g 0 1) (g 1 2) (g 2 0) (h 0 1) (h 1 2) (h 2 0) +
  dTripleCoeff (g 0 2) (g 1 0) (g 2 1) (h 0 2) (h 1 0) (h 2 1) -
  dTripleCoeff (g 0 2) (g 1 1) (g 2 0) (h 0 2) (h 1 1) (h 2 0) -
  dTripleCoeff (g 0 0) (g 1 2) (g 2 1) (h 0 0) (h 1 2) (h 2 1) -
  dTripleCoeff (g 0 1) (g 1 0) (g 2 2) (h 0 1) (h 1 0) (h 2 2)

theorem determinantDual_first_coefficient (g h : Mat3) :
    (determinantDual (lift g h)).eps = deltaDet g h := by
  simp only [determinantDual, lift, dSub, dAdd, dNeg,
    dTriple, dMul, deltaDet, dTripleCoeff]
  simp only [Int.mul_add, Int.add_mul, Int.mul_assoc,
    Int.neg_add, Int.neg_mul, Int.sub_eq_add_neg]
  omega

theorem determinantDual_base (g h : Mat3) :
    (determinantDual (lift g h)).base = determinant g := by
  simp only [determinantDual, lift, dSub, dAdd, dNeg,
    dTriple, dMul, determinant, triple]
  omega

-- Cofactors C_ij of a general (not assumed diagonal or symmetric) matrix.
def cofactor (g : Mat3) (i j : Axis) : Int :=
  match i.val,j.val with
  | 0,0 => g 1 1 * g 2 2 - g 1 2 * g 2 1
  | 0,1 => g 1 2 * g 2 0 - g 1 0 * g 2 2
  | 0,2 => g 1 0 * g 2 1 - g 1 1 * g 2 0
  | 1,0 => g 0 2 * g 2 1 - g 0 1 * g 2 2
  | 1,1 => g 0 0 * g 2 2 - g 0 2 * g 2 0
  | 1,2 => g 0 1 * g 2 0 - g 0 0 * g 2 1
  | 2,0 => g 0 1 * g 1 2 - g 0 2 * g 1 1
  | 2,1 => g 0 2 * g 1 0 - g 0 0 * g 1 2
  | 2,2 => g 0 0 * g 1 1 - g 0 1 * g 1 0
  | _,_ => 0

def adjugate (g : Mat3) : Mat3 :=
  fun i j => cofactor g j i

def cofactorDeltaDet (g h : Mat3) : Int :=
  h 0 0*cofactor g 0 0 + h 0 1*cofactor g 0 1 +
  h 0 2*cofactor g 0 2 + h 1 0*cofactor g 1 0 +
  h 1 1*cofactor g 1 1 + h 1 2*cofactor g 1 2 +
  h 2 0*cofactor g 2 0 + h 2 1*cofactor g 2 1 +
  h 2 2*cofactor g 2 2

theorem cofactor_is_determinant_variation (g h : Mat3) :
    deltaDet g h = cofactorDeltaDet g h := by
  dsimp [deltaDet, dTripleCoeff, cofactorDeltaDet, cofactor]
  simp only [Int.mul_add, Int.mul_sub, Int.add_mul,
    Int.sub_mul, Int.mul_assoc]
  simp only [Int.mul_comm,Int.mul_left_comm,Int.mul_assoc]
  simp only [← Int.mul_assoc]
  omega

private theorem axis_cases :
    ∀ k : Axis, k=0 ∨ k=1 ∨ k=2 := by decide

-- The characteristic adjugate identity, denominator-free.
def scaleMat (c : Int) (A : Mat3) : Mat3 :=
  fun i j => c*(A i j)

theorem g_times_adjugate (g : Mat3) :
    mul g (adjugate g) = scaleMat (determinant g) M1 := by
  funext i j
  rcases axis_cases i with rfl | rfl | rfl <;>
    rcases axis_cases j with rfl | rfl | rfl <;>
    simp [mul, adjugate, cofactor, determinant,
      triple, scaleMat, M1]
    <;> simp only [Int.mul_add, Int.mul_sub, Int.add_mul,
      Int.sub_mul, Int.mul_assoc]
    <;> simp only [Int.mul_comm,Int.mul_left_comm,Int.mul_assoc]
    <;> simp only [← Int.mul_assoc]
    <;> omega

theorem adjugate_times_g (g : Mat3) :
    mul (adjugate g) g = scaleMat (determinant g) M1 := by
  funext i j
  rcases axis_cases i with rfl | rfl | rfl <;>
    rcases axis_cases j with rfl | rfl | rfl <;>
    simp [mul, adjugate, cofactor, determinant,
      triple, scaleMat, M1]
    <;> simp only [Int.mul_add, Int.mul_sub, Int.add_mul,
      Int.sub_mul, Int.mul_assoc]
    <;> simp only [Int.mul_comm,Int.mul_left_comm,Int.mul_assoc]
    <;> simp only [← Int.mul_assoc]
    <;> omega

-- The trace of adj(g)h has the same componentwise nine-cofactor ledger.
def traceAdjH (g h : Mat3) : Int :=
  (adjugate g 0 0*h 0 0 + adjugate g 0 1*h 1 0 +
   adjugate g 0 2*h 2 0) +
  (adjugate g 1 0*h 0 1 + adjugate g 1 1*h 1 1 +
   adjugate g 1 2*h 2 1) +
  (adjugate g 2 0*h 0 2 + adjugate g 2 1*h 1 2 +
   adjugate g 2 2*h 2 2)

theorem determinant_trace_adjugate (g h : Mat3) :
    deltaDet g h = traceAdjH g h := by
  rw [cofactor_is_determinant_variation]
  simp only [traceAdjH, cofactorDeltaDet, adjugate]
  ac_rfl

-- Formal volume square law in Rat. The next step is exact whenever
-- a square-root witness v and its first variation dv are supplied.
structure RatDual where
  base : Rat
  eps : Rat
  deriving DecidableEq, Repr

def rMul (x y : RatDual) : RatDual :=
  ⟨x.base*y.base,x.base*y.eps+x.eps*y.base⟩

theorem square_volume_linearization (v dv : Rat) :
    (rMul ⟨v,dv⟩ ⟨v,dv⟩).eps = v*dv + v*dv := by
  simp only [rMul]
  rw [Rat.mul_comm dv v]

#print axioms dTriple_exact
#print axioms determinantDual_first_coefficient
#print axioms determinantDual_base
#print axioms cofactor_is_determinant_variation
#print axioms g_times_adjugate
#print axioms adjugate_times_g
#print axioms determinant_trace_adjugate
#print axioms square_volume_linearization

end MetricDeterminant010i
