import Init.Data.Rat.Basic
import proofs.Maxwell010b

/-!
# Minimum Mechanics 010c — ADM gravity: normal–normal local algebra

Source: revised Suture Field Dynamics, SD.22–SD.27.
Dependency chain: 010a Dirac chart; 010b Maxwell local algebra.

This certificate proves:
* 3-dimensional symmetric-tensor contractions of the DeWitt kinetic gradient
  against the lapse-Hessian curvature-variation tensor;
* the pointwise antisymmetrized gravitational normal–normal bracket;
* symmetry cancellation of the mixed gradient product;
* an exact Leibniz-jet identity for the flux divergence;
* cancellation of ultralocal gravity–Maxwell cross terms;
* normalization when a = 16πG_N/c³ and b = c³/(16πG_N), a*b = 1;
* a negative control for the essential 1/2 trace coefficient.

Boundary:
The differential-geometric variation of ∫ N√γ R, its boundary term, and the
integration-by-parts theorem for a smooth 3-manifold are *not yet encoded*.
The present algebra lives at one point in an orthonormal spatial coframe,
together with formal first and second jet components. The full functional
Poisson algebra and spacetime dynamics therefore remain OPEN.

No extra axiom, sorry, or Mathlib dependency is introduced.
-/

set_option autoImplicit false

namespace ADMGravity010c

/-! ## Three-dimensional symmetric tensor carrier -/

structure Sym3 where
  xx : Int
  yy : Int
  zz : Int
  xy : Int
  xz : Int
  yz : Int
  deriving DecidableEq, Repr

structure Vec3 where
  x : Int
  y : Int
  z : Int
  deriving DecidableEq, Repr

def trace3 (p : Sym3) : Int := p.xx + p.yy + p.zz

-- Exact symmetric contraction in an orthonormal spatial coframe.
def dot3 (p h : Sym3) : Int :=
  p.xx*h.xx + p.yy*h.yy + p.zz*h.zz +
  2 * (p.xy*h.xy + p.xz*h.xz + p.yz*h.yz)

-- The ADM kinetic derivative has 2 π_ij - γ_ij π in d=3.
-- This is equivalent to 2(π_ij - 1/2 γ_ij π) in SD.26.
def kineticGrad (p : Sym3) : Sym3 :=
  ⟨2*p.xx-trace3 p, 2*p.yy-trace3 p, 2*p.zz-trace3 p,
   2*p.xy, 2*p.xz, 2*p.yz⟩

-- The derivative-bearing term in δ(-b∫N√γ R)/δγ_ij
-- equals b√γ (γ^ij ΔN - D^i D^j N). Here H is the Hessian
-- and ΔN = tr H in an orthonormal coframe.
def curvatureHessianGrad (h : Sym3) : Sym3 :=
  ⟨trace3 h-h.xx, trace3 h-h.yy, trace3 h-h.zz,
   -h.xy, -h.xz, -h.yz⟩

-- Exact rank-three trace cancellation: the π tr(H) terms vanish.
theorem dewitt_hessian_contraction (p h : Sym3) :
    dot3 (kineticGrad p) (curvatureHessianGrad h) =
      -2 * dot3 p h := by
  simp only [dot3, kineticGrad, curvatureHessianGrad, trace3,
    Int.mul_add, Int.mul_sub, Int.sub_mul, Int.add_mul,
    Int.mul_neg, Int.neg_mul, Int.mul_assoc]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
  omega

-- This is the local derivative-bearing antisymmetrized PB contribution;
-- all terms proportional to N*M without lapse derivatives cancel.
def localGravBracket (p hN hM : Sym3) (N M : Int) : Int :=
  M * dot3 (kineticGrad p) (curvatureHessianGrad hN) -
  N * dot3 (kineticGrad p) (curvatureHessianGrad hM)

def localGravFlux (p hN hM : Sym3) (N M : Int) : Int :=
  2 * (N * dot3 p hM - M * dot3 p hN)

theorem gravity_normal_normal_local (p hN hM : Sym3) (N M : Int) :
    localGravBracket p hN hM N M = localGravFlux p hN hM N M := by
  simp only [localGravBracket, localGravFlux,
    dewitt_hessian_contraction, Int.mul_neg, Int.mul_sub, Int.sub_mul,
    Int.mul_assoc]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
  omega

/-! ## Symmetric momenta annihilate the gradient wedge -/

-- π^{ij} (∂i N) (∂j M).
def bilinear3 (p : Sym3) (x y : Vec3) : Int :=
  p.xx*x.x*y.x + p.yy*x.y*y.y + p.zz*x.z*y.z +
  p.xy*(x.x*y.y + x.y*y.x) +
  p.xz*(x.x*y.z + x.z*y.x) +
  p.yz*(x.y*y.z + x.z*y.y)

theorem symmetric_gradient_bilinear (p : Sym3) (x y : Vec3) :
    bilinear3 p x y = bilinear3 p y x := by
  simp only [bilinear3, Int.mul_add]
  ac_rfl

theorem symmetric_gradient_wedge_zero (p : Sym3) (x y : Vec3) :
    bilinear3 p x y - bilinear3 p y x = 0 := by
  rw [symmetric_gradient_bilinear]
  omega

/-! ## Leibniz-jet bridge to spatial divergence -/

-- At each addressed (i,j) slot the current is
-- J_j = N ∂j M - M ∂j N.
-- This formal derivative expands D_i J_j via the product rule.
def gradientCurrent (N M dNj dMj : Int) : Int :=
  N*dMj - M*dNj

def derivativeCurrent (N M dNi dMi dNj dMj hNij hMij : Int) : Int :=
  dNi*dMj + N*hMij - dMi*dNj - M*hNij

def derivativeFlux (p dp N M dNi dMi dNj dMj hNij hMij : Int) : Int :=
  dp * gradientCurrent N M dNj dMj +
  p * derivativeCurrent N M dNi dMi dNj dMj hNij hMij

theorem flux_leibniz_decomposition
    (p dp N M dNi dMi dNj dMj hNij hMij : Int) :
    derivativeFlux p dp N M dNi dMi dNj dMj hNij hMij =
    dp * (N*dMj - M*dNj) +
    p * (N*hMij - M*hNij) +
    p * (dNi*dMj - dMi*dNj) := by
  simp only [derivativeFlux, derivativeCurrent, gradientCurrent,
    Int.mul_add, Int.mul_sub, Int.add_mul, Int.sub_mul, Int.mul_assoc]
  omega

-- The previous tensor theorem cancels the final term upon summing
-- the six symmetric tensor slots of a spatial 3×3 matrix.
-- The remaining divergence term becomes the ADM momentum constraint
-- after integration by parts (analytic boundary, not proved here).

/-! ## Matter cross-bracket and gravitational couplings -/

-- Both the electric and magnetic Maxwell Hamiltonian densities depend
-- on γ and E,F but never on the gravitational momentum π.
-- The cross terms have the same factor N*M and cancel identically.
theorem ultralocal_gravity_maxwell_cross_cancel
    (N M kineticMetricResponse matterMetricResponse : Int) :
    (N * kineticMetricResponse) * (M * matterMetricResponse) -
    (M * kineticMetricResponse) * (N * matterMetricResponse) = 0 := by
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
  omega

-- a,b are the two dimensionful coefficients of SD.26, represented
-- by a,b ∈ ℚ and an explicit reciprocal witness; the result does not
-- assume either coefficient equals 1 separately.
theorem gravitational_ab_normalization
    (a b X : Rat) (hab : a*b = 1) :
    a*(b*X) = X := by
  rw [← Rat.mul_assoc, hab]
  simp

-- The ADM coefficient 1/2 is load-bearing: remove its trace term and
-- even a simple diagonal momentum/Hessian pair leaves an uncancelled
-- trace–Laplacian contribution.
def wrongKineticGrad (p : Sym3) : Sym3 :=
  ⟨2*p.xx, 2*p.yy, 2*p.zz, 2*p.xy, 2*p.xz, 2*p.yz⟩

def testP : Sym3 := ⟨1, 0, 0, 0, 0, 0⟩
def testH : Sym3 := ⟨1, 0, 0, 0, 0, 0⟩

theorem negative_control_without_trace :
    dot3 (wrongKineticGrad testP) (curvatureHessianGrad testH) ≠
      -2 * dot3 testP testH := by decide

#print axioms dewitt_hessian_contraction
#print axioms gravity_normal_normal_local
#print axioms symmetric_gradient_bilinear
#print axioms symmetric_gradient_wedge_zero
#print axioms flux_leibniz_decomposition
#print axioms ultralocal_gravity_maxwell_cross_cancel
#print axioms gravitational_ab_normalization
#print axioms negative_control_without_trace

end ADMGravity010c
