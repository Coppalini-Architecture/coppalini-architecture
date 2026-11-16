import Init.Data.Rat.Basic
import proofs.CanonicalTwoSite010m

/-!
# Minimum Mechanics 010m — closed finite canonical quadratic transport algebra

A separate, **genuine** four-dimensional symplectic phase-space model
has q0,q1,p0,p1 with the exact canonical bracket of 010m.

For any symmetric 2×2 matrix W=[[a,b],[b,c]], define
 H_W = a(q0²+p0²)+2b(q0 q1+p0 p1)+c(q1²+p1²).

For any antisymmetric T_t=[[0,-t],[t,0]], define
 D_t = t(p1 q0-p0 q1).

The gradient of each observable is explicitly obtained from the above
polynomials. The canonical PB then proves, **without any assumed closure**:
 {D_t,H_W}=H_[T_t,W],
 {H_W,H_V}=D_(4[(a-c)e+(f-d)b]),
 {D_t,D_s}=0.
This is a finite-dimensional symplectic Lie-algebra representation.
It is not the ADM hypersurface-deformation algebra: its structure
constants are algebraic and it carries no dynamical spatial metric,
diffeomorphism constraint functional or boundary space.

The two-site scalar model in CanonicalTwoSite010m is an independent
finite field model; its D-H obstruction is preserved, not bypassed.
No axioms, sorry, or Mathlib.
-/
set_option autoImplicit false
namespace QuadraticTransport010m

open CanonicalTwoSite010m

structure W where
  a : Int
  b : Int
  c : Int
  deriving DecidableEq, Repr

def H (w : W) (x : Phase) : Int :=
  w.a*(x.q0*x.q0 + x.p0*x.p0) +
  2*w.b*(x.q0*x.q1 + x.p0*x.p1) +
  w.c*(x.q1*x.q1 + x.p1*x.p1)

def D (t : Int) (x : Phase) : Int :=
  t*(x.p1*x.q0 - x.p0*x.q1)

def gradH (w : W) (x : Phase) : Gradient :=
  ⟨2*w.a*x.q0+2*w.b*x.q1,
   2*w.b*x.q0+2*w.c*x.q1,
   2*w.a*x.p0+2*w.b*x.p1,
   2*w.b*x.p0+2*w.c*x.p1⟩

def gradD (t : Int) (x : Phase) : Gradient :=
  ⟨t*x.p1, -t*x.p0,-t*x.q1,t*x.q0⟩

-- A nonlinear polynomial-gradient witness (derivative wrt q0).
theorem H_first_q0 (w : W) (x : Phase) (z : Int) :
    H w {x with q0 := x.q0+z} =
      H w x + z*(gradH w x).q0 + w.a*z*z := by
  simp only [H, gradH, Int.add_mul, Int.mul_add,
    Int.mul_assoc]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
  omega

theorem D_first_p1 (t : Int) (x : Phase) (z : Int) :
    D t {x with p1 := x.p1+z} =
      D t x + z*(gradD t x).p1 := by
  simp only [D, gradD, Int.add_mul, Int.mul_add,
    Int.mul_assoc]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
  omega

def PB_DH (t : Int) (w : W) (x : Phase) : Int :=
  symplectic (gradD t x) (gradH w x)

def PB_HH (w v : W) (x : Phase) : Int :=
  symplectic (gradH w x) (gradH v x)

def PB_DD (t s : Int) (x : Phase) : Int :=
  symplectic (gradD t x) (gradD s x)

-- In coordinates [T,W]=[[ -2tb, t(a-c) ],
--                      [ t(a-c), 2tb ]]
def transportW (t : Int) (w : W) : W :=
  ⟨-2*t*w.b,t*(w.a-w.c),2*t*w.b⟩

-- The two symmetric weights W,V have a skew commutator with a single
-- independent off-diagonal entry. Its coefficient is directly computed.
def normalShift (w v : W) : Int :=
  4 * ((w.a-w.c)*v.b + (v.c-v.a)*w.b)

theorem exact_momentum_hamiltonian (t : Int) (w : W) (x : Phase) :
    PB_DH t w x = H (transportW t w) x := by
  simp only [PB_DH, symplectic, gradD, gradH, H, transportW]
  simp only [Int.mul_add, Int.mul_sub, Int.add_mul, Int.sub_mul,
    Int.neg_mul, Int.mul_neg, Int.mul_assoc]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
  simp only [← Int.mul_assoc]
  omega

theorem exact_normal_normal (w v : W) (x : Phase) :
    PB_HH w v x = D (normalShift w v) x := by
  simp only [PB_HH, symplectic, gradD, gradH, D, normalShift]
  simp only [Int.mul_add, Int.mul_sub, Int.add_mul, Int.sub_mul,
    Int.neg_mul, Int.mul_neg, Int.mul_assoc]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
  simp only [← Int.mul_assoc]
  omega

theorem exact_transport_transport (t s : Int) (x : Phase) :
    PB_DD t s x = 0 := by
  simp only [PB_DD, symplectic, gradD]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
  omega

theorem normal_shift_skew (w v : W) :
    normalShift w v = -normalShift v w := by
  simp only [normalShift, Int.mul_add, Int.mul_sub,
    Int.add_mul, Int.sub_mul, Int.mul_assoc]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
  omega

theorem isotropic_H_invariant (t a : Int) (x : Phase) :
    PB_DH t ⟨a,0,a⟩ x = 0 := by
  rw [exact_momentum_hamiltonian]
  simp [transportW, H]

def skewExample : W := ⟨1,0,0⟩
def skewExample2 : W := ⟨0,1,0⟩
def xExample : Phase := ⟨1,0,0,1⟩

theorem genuine_nonzero_normal_bracket :
    PB_HH skewExample skewExample2 xExample = 4 := by decide

-- This finite algebra closes by actual canonical PB, but the shift
-- depends on the W,V matrix commutator, not the ADM dynamical metric.
theorem finite_canonical_quadratic_closure (t s : Int) (w v : W)
    (x : Phase) :
    PB_DD t s x = 0 ∧
    PB_DH t w x = H (transportW t w) x ∧
    PB_HH w v x = D (normalShift w v) x := by
  exact ⟨exact_transport_transport t s x,
    exact_momentum_hamiltonian t w x,
    exact_normal_normal w v x⟩

#print axioms H_first_q0
#print axioms D_first_p1
#print axioms exact_momentum_hamiltonian
#print axioms exact_normal_normal
#print axioms exact_transport_transport
#print axioms normal_shift_skew
#print axioms isotropic_H_invariant
#print axioms genuine_nonzero_normal_bracket
#print axioms finite_canonical_quadratic_closure

end QuadraticTransport010m
