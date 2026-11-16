import Init.Data.Rat.Basic
import proofs.DoubleStokes010l
import proofs.CanonicalPoisson010f

/-!
# Minimum Mechanics 010m — two-site canonical scalar-field Hamiltonian

Fixed 010a–010l source addresses and proof strengths remain unchanged.

CONSTRUCTION:
A genuine finite canonical phase space has q₀,q₁,p₀,p₁∈ℤ, with
  {q_a,p_b}=δ_ab.  The smearing pair n=(n₀,n₁) and gradient coupling
κ∈ℤ determine the polynomial Hamiltonian
  Hκ[n] = n₀p₀² + n₁p₁² + κ(n₀+n₁)(q₁-q₀)².
The physical 1/2 and spatial edge-weight factors are absorbed into this
INTEGER-NORMALIZED representative. All normalization factors of the
physical ADM source remain separate and unchanged.

The code computes every canonical gradient from the POLYNOMIAL Hκ,
then defines the bracket directly from those gradients:
  {Hκ[n], Hκ[m]}
    = 4κ(n₀m₁-n₁m₀)(q₁-q₀)(p₀+p₁).

Define D[w] = w(q₁-q₀)(p₀+p₁).  The above is the complete
normal–normal bracket of this explicitly specified two-site
SCALAR-FIELD model, not Einstein–Maxwell–ADM.

It additionally checks the D–H Poisson bracket and provides a
counterexample to identifying its D–H result as any Hamiltonian
smearing within this 2-site family. Finite edge differencing does
not carry the continuum Leibniz/smooth-diffeomorphism identity.

No false identification with a continuum field functional, no
claims for general smooth metrics, no sorry/axioms/Mathlib.
-/
set_option autoImplicit false
namespace CanonicalTwoSite010m

structure Phase where
  q0 : Int
  q1 : Int
  p0 : Int
  p1 : Int
  deriving DecidableEq, Repr

structure Smear where
  n0 : Int
  n1 : Int
  deriving DecidableEq, Repr

def gap (x : Phase) : Int := x.q1 - x.q0
def momentumSum (x : Phase) : Int := x.p0 + x.p1

def H (κ : Int) (n : Smear) (x : Phase) : Int :=
  n.n0*(x.p0*x.p0) + n.n1*(x.p1*x.p1) +
    (κ*(n.n0+n.n1))*(gap x*gap x)

def gradQ0 (κ : Int) (n : Smear) (x : Phase) : Int :=
  -(2*(κ*(n.n0+n.n1))*gap x)
def gradQ1 (κ : Int) (n : Smear) (x : Phase) : Int :=
  2*(κ*(n.n0+n.n1))*gap x
def gradP0 (_κ : Int) (n : Smear) (x : Phase) : Int :=
  2*n.n0*x.p0
def gradP1 (_κ : Int) (n : Smear) (x : Phase) : Int :=
  2*n.n1*x.p1

-- Exact weighted second-order Taylor coefficient for one integer square.
-- This lemma is derived using the inherited 010b quadratic identity.
theorem weighted_square_shift (c u t : Int) :
    c*((u+t)*(u+t)) =
      c*(u*u) + t*(2*c*u) + c*(t*t) := by
  have h0 := Maxwell010b.product_variation u u 1 1 t
  simp only [Int.mul_one] at h0
  have htwo : u+u=2*u := by omega
  have hcross : c*(t*(u+u))=t*(2*c*u) := by
    calc
      c*(t*(u+u)) = c*(t*(2*u)) := by rw [htwo]
      _ = t*(2*c*u) := by ac_rfl
  calc
    c*((u+t)*(u+t)) =
        c*(u*u + t*(u+u) + t*t) := by rw [h0]
    _ = c*(u*u)+c*(t*(u+u))+c*(t*t) := by
      simp only [Int.mul_add]
    _ = c*(u*u)+t*(2*c*u)+c*(t*t) := by rw [hcross]

theorem weighted_square_sub (c u t : Int) :
    c*((u-t)*(u-t)) =
      c*(u*u) + t*(-2*c*u) + c*(t*t) := by
  have h := weighted_square_shift c u (-t)
  simp only [Int.sub_eq_add_neg]
  rw [h]
  simp only [Int.neg_mul, Int.mul_neg, Int.neg_neg]
  omega

-- Each Hessian/t² remainder is preserved explicitly. Thus the
-- gradient used in the canonical bracket is the actual first
-- Taylor coefficient of H, rather than a freely assigned response.
theorem derivative_p0_exact (κ : Int) (n : Smear)
    (x : Phase) (t : Int) :
    H κ n {x with p0 := x.p0+t} =
      H κ n x + t * gradP0 κ n x + n.n0*t*t := by
  have h := weighted_square_shift n.n0 x.p0 t
  simp only [H, gradP0, gap] at ⊢
  rw [h]
  simp only [Int.mul_assoc]
  omega

theorem derivative_p1_exact (κ : Int) (n : Smear)
    (x : Phase) (t : Int) :
    H κ n {x with p1 := x.p1+t} =
      H κ n x + t * gradP1 κ n x + n.n1*t*t := by
  have h := weighted_square_shift n.n1 x.p1 t
  simp only [H, gradP1, gap] at ⊢
  rw [h]
  simp only [Int.mul_assoc]
  omega

theorem derivative_q0_exact (κ : Int) (n : Smear)
    (x : Phase) (t : Int) :
    H κ n {x with q0 := x.q0+t} =
      H κ n x + t * gradQ0 κ n x +
       κ*(n.n0+n.n1)*t*t := by
  have hgap : (x.q1-(x.q0+t)) = gap x-t := by
    simp only [gap]
    omega
  have h := weighted_square_sub (κ*(n.n0+n.n1)) (gap x) t
  simp only [H, gradQ0] at ⊢
  change n.n0*(x.p0*x.p0)+n.n1*(x.p1*x.p1) +
      (κ*(n.n0+n.n1))*((x.q1-(x.q0+t))*(x.q1-(x.q0+t))) =
    n.n0*(x.p0*x.p0)+n.n1*(x.p1*x.p1) +
      (κ*(n.n0+n.n1))*(gap x*gap x) +
      t*(-(2*(κ*(n.n0+n.n1))*gap x)) +
      κ*(n.n0+n.n1)*t*t
  rw [hgap, h]
  simp only [Int.mul_assoc, Int.neg_mul, Int.mul_neg]
  omega

theorem derivative_q1_exact (κ : Int) (n : Smear)
    (x : Phase) (t : Int) :
    H κ n {x with q1 := x.q1+t} =
      H κ n x + t * gradQ1 κ n x +
        κ*(n.n0+n.n1)*t*t := by
  have hgap : ((x.q1+t)-x.q0) = gap x+t := by
    simp only [gap]
    omega
  have h := weighted_square_shift (κ*(n.n0+n.n1)) (gap x) t
  simp only [H, gradQ1] at ⊢
  change n.n0*(x.p0*x.p0)+n.n1*(x.p1*x.p1) +
      (κ*(n.n0+n.n1))*(((x.q1+t)-x.q0)*((x.q1+t)-x.q0)) =
    n.n0*(x.p0*x.p0)+n.n1*(x.p1*x.p1) +
      (κ*(n.n0+n.n1))*(gap x*gap x) +
      t*(2*(κ*(n.n0+n.n1))*gap x) +
      κ*(n.n0+n.n1)*t*t
  rw [hgap, h]
  simp only [Int.mul_assoc]
  omega

-- Full canonical symplectic Poisson tensor for arbitrary four
-- gradient entries (F_q0, F_q1, F_p0, F_p1).
structure Gradient where
  q0 : Int
  q1 : Int
  p0 : Int
  p1 : Int
  deriving DecidableEq, Repr

def symplectic (f g : Gradient) : Int :=
  f.q0*g.p0 + f.q1*g.p1 -
  f.p0*g.q0 - f.p1*g.q1

def HGradient (κ : Int) (n : Smear) (x : Phase) : Gradient :=
  ⟨gradQ0 κ n x, gradQ1 κ n x,
   gradP0 κ n x, gradP1 κ n x⟩

def HamiltonianBracket (κ : Int) (n m : Smear) (x : Phase) : Int :=
  symplectic (HGradient κ n x) (HGradient κ m x)

theorem symplectic_antisymmetric (f g : Gradient) :
    symplectic f g = -symplectic g f := by
  simp only [symplectic]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
  omega

theorem symplectic_self_zero (f : Gradient) :
    symplectic f f = 0 := by
  simp only [symplectic]
  rw [Int.mul_comm f.p0 f.q0, Int.mul_comm f.p1 f.q1]
  omega

def wedge (n m : Smear) : Int :=
  n.n0*m.n1-n.n1*m.n0

def D (w : Int) (x : Phase) : Int :=
  w * gap x * momentumSum x

theorem Hamiltonian_normal_normal_exact (κ : Int)
    (n m : Smear) (x : Phase) :
    HamiltonianBracket κ n m x =
      D (4*κ*wedge n m) x := by
  simp only [HamiltonianBracket, symplectic, HGradient,
    gradQ0, gradQ1, gradP0, gradP1,
    D, wedge, gap, momentumSum]
  simp only [Int.mul_add, Int.mul_sub, Int.add_mul, Int.sub_mul,
    Int.neg_mul, Int.mul_neg, Int.mul_assoc]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
  simp only [← Int.mul_assoc]
  omega

theorem lapse_wedge_alternating (n m : Smear) :
    wedge n m = -wedge m n := by
  simp only [wedge]
  rw [Int.mul_comm m.n0 n.n1, Int.mul_comm m.n1 n.n0]
  omega

theorem homogeneous_lapse_bracket_zero (κ : Int) (n : Smear)
    (x : Phase) : HamiltonianBracket κ n n x = 0 := by
  rw [Hamiltonian_normal_normal_exact]
  have hw : wedge n n = 0 := by
    simp only [wedge]
    rw [Int.mul_comm n.n1 n.n0]
    omega
  rw [hw]
  simp [D]

theorem uncoupled_bracket_zero (n m : Smear)
    (x : Phase) : HamiltonianBracket 0 n m x = 0 := by
  rw [Hamiltonian_normal_normal_exact]
  simp [D]

-- Momentum generator D[1] also has a genuine canonical differential.
def DGradient (x : Phase) : Gradient :=
  ⟨-momentumSum x, momentumSum x, gap x, gap x⟩

theorem derivative_D_p0 (x : Phase) (t : Int) :
    D 1 {x with p0 := x.p0+t} =
      D 1 x + t * (DGradient x).p0 := by
  simp only [D, gap, momentumSum, DGradient, Int.add_mul,
    Int.mul_add, Int.mul_assoc]
  simp only [Int.one_mul, Int.mul_one, Int.mul_assoc]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
  omega

theorem derivative_D_q0 (x : Phase) (t : Int) :
    D 1 {x with q0 := x.q0+t} =
      D 1 x + t * (DGradient x).q0 := by
  simp only [D, gap, momentumSum, DGradient, Int.add_mul,
    Int.mul_add, Int.mul_sub, Int.sub_mul, Int.mul_assoc]
  simp only [Int.one_mul, Int.mul_one, Int.mul_assoc,
    Int.neg_mul, Int.mul_neg]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
  omega

def MomentumHamiltonianBracket (κ : Int) (n : Smear)
    (x : Phase) : Int :=
  symplectic (DGradient x) (HGradient κ n x)

def MomentumHamiltonianResponse (n : Smear) (x : Phase) : Int :=
  2 * momentumSum x * (n.n1*x.p1 - n.n0*x.p0)

theorem momentum_hamiltonian_exact (κ : Int) (n : Smear)
    (x : Phase) :
    MomentumHamiltonianBracket κ n x =
      MomentumHamiltonianResponse n x := by
  simp only [MomentumHamiltonianBracket, MomentumHamiltonianResponse,
    symplectic, DGradient, HGradient, gradQ0, gradQ1,
    gradP0, gradP1, gap, momentumSum]
  simp only [Int.mul_add, Int.mul_sub, Int.add_mul, Int.sub_mul,
    Int.neg_mul, Int.mul_neg, Int.mul_assoc]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
  simp only [← Int.mul_assoc]
  omega

-- This one genuine counterexample is a critical scope guard:
-- finite-edge differencing does not preserve the continuum D–H
-- hypersurface-deformation identity for general inhomogeneous lapse.
def nOne : Smear := ⟨1,0⟩
def basePhase (u v : Int) : Phase := ⟨0,0,u,v⟩

theorem no_two_site_lapse_representation :
    ∀ m : Smear,
      ¬ (∀ x : Phase,
          MomentumHamiltonianBracket 1 nOne x = H 1 m x) := by
  intro m h
  have h11 := h (basePhase 1 1)
  have h10 := h (basePhase 1 0)
  have h01 := h (basePhase 0 1)
  rw [momentum_hamiltonian_exact] at h11 h10 h01
  simp only [MomentumHamiltonianResponse, momentumSum, basePhase,
    gap, nOne, H] at h11 h10 h01
  omega

theorem explicit_nonzero_normal_bracket :
    HamiltonianBracket 1 ⟨1,0⟩ ⟨0,1⟩
      ⟨0,1,1,1⟩ = 8 := by decide

#print axioms weighted_square_shift
#print axioms weighted_square_sub
#print axioms derivative_p0_exact
#print axioms derivative_p1_exact
#print axioms derivative_q0_exact
#print axioms derivative_q1_exact
#print axioms symplectic_antisymmetric
#print axioms Hamiltonian_normal_normal_exact
#print axioms momentum_hamiltonian_exact
#print axioms no_two_site_lapse_representation
#print axioms explicit_nonzero_normal_bracket

end CanonicalTwoSite010m
