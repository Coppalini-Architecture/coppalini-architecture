import Init.Data.Rat.Basic
import proofs.MetricVolume010k

/-!
# Minimum Mechanics 010p — nonorthonormal DeWitt-Hessian contraction

The 010c certificate proved the gravitational normal-normal DeWitt
contraction in an orthonormal spatial coframe. Here g and B are arbitrary
3×3 integer matrices satisfying gB=Bg=I. The metric, inverse and all
contractions remain explicit, including a nonorthonormal example.

For contravariant momentum P and covariant Hessian H, let
  τ=tr(g P),    λ=tr(B H).
  K=2 g P g - τ g                   (ADM kinetic gradient)
  C=λ B - B H B                    (curvature Hessian gradient).
Then
  tr(K C) = -2 tr(P H)
for every g,B,P,H under the inverse hypotheses. This is an algebraic
tensor identity; the physical scalar factors a/sqrt(g), b sqrt(g)
multiply to ab=1 as proved independently in 010c.

The result upgrades the local DeWitt reader to nonorthonormal metric
coordinates. It does not construct the smooth Einstein-Hilbert functional
gradient or a global positive-definite metric. That analytic seam
remains OPEN. No new axioms, sorry or Mathlib dependency.
-/

set_option autoImplicit false
namespace DeWittCovariant010p

open MetricInverse010i MetricVolume010k
abbrev M := MetricInverse010i.Mat3

def scale (t : Int) (A : M) : M :=
  fun i j => t*A i j

def sub (A B : M) : M :=
  fun i j => A i j - B i j

def tr (A : M) : Int := MetricVolume010k.traceMat A

theorem trace_add (A B : M) :
    tr (add A B) = tr A + tr B := by
  exact MetricVolume010k.traceMat_add A B

theorem trace_scale (t : Int) (A : M) :
    tr (scale t A) = t*tr A := by
  simp only [tr, MetricVolume010k.traceMat, scale,
    Int.mul_add]

theorem trace_sub (A B : M) :
    tr (sub A B) = tr A-tr B := by
  simp only [tr, MetricVolume010k.traceMat, sub]
  omega

theorem mul_scale_left (t : Int) (A B : M) :
    mul (scale t A) B = scale t (mul A B) := by
  funext i j
  simp only [mul, scale, Int.mul_add, Int.mul_assoc]

theorem mul_scale_right (t : Int) (A B : M) :
    mul A (scale t B) = scale t (mul A B) := by
  funext i j
  simp only [mul, scale, Int.mul_add, Int.mul_assoc]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]

theorem mul_sub_right (A B C : M) :
    mul A (sub B C) = sub (mul A B) (mul A C) := by
  funext i j
  simp only [mul, sub, Int.mul_sub]
  omega

theorem mul_sub_left (A B C : M) :
    mul (sub A B) C = sub (mul A C) (mul B C) := by
  funext i j
  simp only [mul, sub, Int.sub_mul]
  omega

theorem tr_one : tr M1 = 3 := by decide

theorem tr_mul_comm (A B : M) :
    tr (mul A B) = tr (mul B A) :=
  MetricVolume010k.trace_mul_comm A B

theorem tr_mul_cycle (A B C : M) :
    tr (mul A (mul B C)) = tr (mul B (mul C A)) := by
  calc
    tr (mul A (mul B C)) =
      tr (mul (mul B C) A) := tr_mul_comm A _
    _ = tr (mul B (mul C A)) := by rw [mul_assoc]

def tau (g P : M) : Int := tr (mul g P)
def lambda (B H : M) : Int := tr (mul B H)

def kineticGradient (g P : M) : M :=
  sub (scale 2 (mul (mul g P) g)) (scale (tau g P) g)

def hessianGradient (B H : M) : M :=
  sub (scale (lambda B H) B) (mul (mul B H) B)

theorem trace_kinetic_B
    (g B P : M) (hgB : mul g B = M1) :
    tr (mul (kineticGradient g P) B) = -(tau g P) := by
  have h1 : tr (mul (mul (mul g P) g) B) = tau g P := by
    calc
      tr (mul (mul (mul g P) g) B) =
        tr (mul (mul g P) (mul g B)) := by rw [mul_assoc]
      _ = tau g P := by rw [hgB, mul_one]; rfl
  calc
    tr (mul (kineticGradient g P) B) =
        2*tr (mul (mul (mul g P) g) B) -
        tau g P * tr (mul g B) := by
      simp only [kineticGradient, mul_sub_left,
        mul_scale_left, trace_sub, trace_scale]
    _ = -(tau g P) := by rw [h1, hgB, tr_one]; omega

theorem trace_kinetic_BHB
    (g B P H : M)
    (hgB : mul g B = M1) (hBg : mul B g = M1) :
    tr (mul (kineticGradient g P) (mul (mul B H) B)) =
      2*tr (mul P H) - (tau g P)*(lambda B H) := by
  have hG : mul g (mul (mul B H) B) = mul H B := by
    calc
      mul g (mul (mul B H) B) =
        mul (mul g (mul B H)) B := by rw [← mul_assoc]
      _ = mul (mul (mul g B) H) B := by rw [← mul_assoc]
      _ = mul H B := by rw [hgB, one_mul]
  have h1 :
      tr (mul (mul (mul g P) g) (mul (mul B H) B)) =
        tr (mul P H) := by
    calc
      tr (mul (mul (mul g P) g) (mul (mul B H) B)) =
        tr (mul (mul g P) (mul g (mul (mul B H) B))) := by
          rw [mul_assoc]
      _ = tr (mul (mul g P) (mul H B)) := by rw [hG]
      _ = tr (mul (mul (mul g P) H) B) := by simp only [mul_assoc]
      _ = tr (mul B (mul (mul g P) H)) := tr_mul_comm _ _
      _ = tr (mul (mul B g) (mul P H)) := by
          simp only [mul_assoc]
      _ = tr (mul P H) := by rw [hBg, one_mul]
  have h2 : tr (mul g (mul (mul B H) B)) =
      lambda B H := by
    calc
      tr (mul g (mul (mul B H) B)) =
        tr (mul (mul g B) (mul H B)) := by
          rw [mul_assoc, ← mul_assoc B H B, mul_assoc]
      _ = tr (mul H B) := by rw [hgB, one_mul]
      _ = lambda B H := by
        rw [tr_mul_comm H B]
        rfl
  calc
    tr (mul (kineticGradient g P) (mul (mul B H) B)) =
        2*tr (mul (mul (mul g P) g) (mul (mul B H) B)) -
        (tau g P)*tr (mul g (mul (mul B H) B)) := by
      simp only [kineticGradient, mul_sub_left,
        mul_scale_left, trace_sub, trace_scale]
    _ = 2*tr (mul P H) - (tau g P)*(lambda B H) := by rw [h1,h2]

theorem covariant_dewitt_hessian
    (g B P H : M)
    (hgB : mul g B = M1) (hBg : mul B g = M1) :
    tr (mul (kineticGradient g P) (hessianGradient B H)) =
      -2 * tr (mul P H) := by
  calc
    tr (mul (kineticGradient g P) (hessianGradient B H)) =
      (lambda B H)*tr (mul (kineticGradient g P) B) -
      tr (mul (kineticGradient g P) (mul (mul B H) B)) := by
        simp only [hessianGradient, mul_sub_right,
          mul_scale_right, trace_sub, trace_scale]
    _ = -2 * tr (mul P H) := by
      rw [trace_kinetic_B g B P hgB,
        trace_kinetic_BHB g B P H hgB hBg]
      simp only [Int.mul_neg, Int.neg_mul]
      omega

#print axioms trace_kinetic_B
#print axioms trace_kinetic_BHB
#print axioms covariant_dewitt_hessian

end DeWittCovariant010p
