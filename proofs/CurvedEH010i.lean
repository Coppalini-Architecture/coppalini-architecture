import Init.Data.Rat.Basic
import proofs.MetricDeterminant010i
import proofs.ConnectionPalatini010h

/-!
# Minimum Mechanics 010i — curved Einstein–Hilbert density first variation

CONTEXT:
010h provides an exact Palatini connection-curvature differential, including
the quadratic remainder, plus the integrated flat-background EH Hessian.
010i adds pointwise *nonflat* metric inversion and determinant differentials.

CERTIFIED HERE:
1. For gB=I, adj(g) = det(g) B and
   d(det g)(h) = det(g) tr(Bh), as exact integer identities.
2. A formal volume v with v*v=det(g) and first-order square relation
   v*dv+v*dv=d(det g)(h) has the denominator-free response
   v*dv+v*dv = v*v tr(Bh).
3. The full pointwise first-order density response of v(R-2Lambda), with
   R=tr(B Ric) and dR=tr(dB Ric)+tr(B dRic), retaining all curved R terms.
4. The Christoffel numerator and 2Gamma=g^-1(dg+dg-dg) have an exact
   first-order metric/connection response, including quadratic residual.

JURISDICTION:
All fields in this file are pointwise integer matrices and their formal
first jets. The square-root variable v is a *witness*; a smooth positive
Riemannian volume form and its differentiability are not constructed.
Ricci first variations are independent tensor data; their Palatini
derivatives and integration by parts are addressed by prior modules and
require a smooth covariant Stokes realization on an actual manifold.
This file proves neither global smooth Einstein–Hilbert differentiability
nor the full first-class Dirac–ADM algebra.

Core Lean 4.33.0 · no Mathlib · no sorry · no new axioms.
-/
set_option autoImplicit false
namespace CurvedEH010i

open MetricInverse010i MetricDeterminant010i

def traceProduct (B Ric : Mat3) : Int :=
  (B 0 0*Ric 0 0+B 0 1*Ric 1 0+B 0 2*Ric 2 0) +
  (B 1 0*Ric 0 1+B 1 1*Ric 1 1+B 1 2*Ric 2 1) +
  (B 2 0*Ric 0 2+B 2 1*Ric 1 2+B 2 2*Ric 2 2)

theorem scale_left (c : Int) (A B : Mat3) :
    mul (scaleMat c A) B = scaleMat c (mul A B) := by
  funext i j
  simp only [mul, scaleMat, Int.mul_add, Int.mul_assoc]
  omega

theorem adjugate_is_det_inverse
    (g B : Mat3) (hRight : mul g B = M1) :
    adjugate g = scaleMat (determinant g) B := by
  calc
    adjugate g = mul (adjugate g) M1 :=
      (mul_one (adjugate g)).symm
    _ = mul (adjugate g) (mul g B) := by rw [hRight]
    _ = mul (mul (adjugate g) g) B :=
      (mul_assoc (adjugate g) g B).symm
    _ = mul (scaleMat (determinant g) M1) B := by
      rw [adjugate_times_g]
    _ = scaleMat (determinant g) B := by
      rw [scale_left, one_mul]

theorem determinant_Jacobi_trace
    (g B h : Mat3) (hRight : mul g B = M1) :
    deltaDet g h = determinant g * traceProduct B h := by
  rw [determinant_trace_adjugate]
  rw [adjugate_is_det_inverse g B hRight]
  simp only [traceAdjH, traceProduct, scaleMat, Int.mul_add,
    Int.mul_assoc]
  omega

-- A first-order volume root is declared by two exact algebraic equations.
structure VolumeRoot (g h : Mat3) where
  v : Int
  dv : Int
  square : v*v = determinant g
  firstOrderSquare : v*dv+v*dv = deltaDet g h

theorem volume_density_Jacobi
    (g B h : Mat3) (hRight : mul g B = M1)
    (root : VolumeRoot g h) :
    root.v * root.dv + root.v * root.dv =
      (root.v*root.v) * traceProduct B h := by
  rw [root.firstOrderSquare]
  rw [determinant_Jacobi_trace g B h hRight]
  rw [root.square]

-- The metric inverse response was proved in MetricInverse010i:
-- dB = - B h B. We retain it unchanged and reuse it in the trace.
def deltaScalarCurvature (B h Ric dRic : Mat3) : Int :=
  traceProduct (dInverse B h) Ric + traceProduct B dRic

def scalarCurvature (B Ric : Mat3) : Int :=
  traceProduct B Ric

theorem trace_neg (A Ric : Mat3) :
    traceProduct (neg A) Ric = -(traceProduct A Ric) := by
  simp only [traceProduct, neg, Int.neg_mul]
  omega

theorem curved_scalar_curvature_differential
    (B h Ric dRic : Mat3) :
    deltaScalarCurvature B h Ric dRic =
      traceProduct B dRic -
        traceProduct (mul B (mul h B)) Ric := by
  simp only [deltaScalarCurvature, dInverse]
  rw [trace_neg]
  omega

-- The full Einstein-Hilbert density (with cosmological term) at a point:
--     L = v (R - 2Lambda),  v² = det(g).
def EHdensity (v : Int) (B Ric : Mat3) (Lambda : Int) : Int :=
  v*(scalarCurvature B Ric-2*Lambda)

def deltaEHdensity (v dv : Int) (B h Ric dRic : Mat3)
    (Lambda : Int) : Int :=
  dv*(scalarCurvature B Ric-2*Lambda) +
    v*deltaScalarCurvature B h Ric dRic

-- The tensorial *pointwise* density variation, with the correct
-- curved Ricci response. All operations are exact and branch-free.
theorem curved_EH_density_first_variation
    (g B h Ric dRic : Mat3) (Lambda : Int)
    (hRight : mul g B = M1) (root : VolumeRoot g h) :
    root.v*deltaEHdensity root.v root.dv B h Ric dRic Lambda +
    root.v*deltaEHdensity root.v root.dv B h Ric dRic Lambda =
      determinant g *
      (traceProduct B h * (scalarCurvature B Ric - 2*Lambda) +
       2*(traceProduct B dRic -
          traceProduct (mul B (mul h B)) Ric)) := by
  have hVol := volume_density_Jacobi g B h hRight root
  have hCurv := curved_scalar_curvature_differential B h Ric dRic
  simp only [deltaEHdensity] at ⊢
  rw [hCurv]
  rw [root.square] at hVol
  simp only [Int.mul_add, Int.mul_sub, Int.add_mul, Int.sub_mul,
    Int.mul_assoc]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
  simp only [← Int.mul_assoc]
  omega

/-! ## Levi-Civita first variation before Palatini contraction -/

abbrev Axis := Fin 3
abbrev MetricJet := Axis → Axis → Axis → Int

def numerator (dg : MetricJet) (i j l : Axis) : Int :=
  dg i j l + dg j i l - dg l i j

def twiceGamma (B : Mat3) (dg : MetricJet)
    (k i j : Axis) : Int :=
  B k 0*numerator dg i j 0 +
  B k 1*numerator dg i j 1 +
  B k 2*numerator dg i j 2

def shiftJet (dg dh : MetricJet) (t : Int) : MetricJet :=
  fun a i j => dg a i j + t*dh a i j

def scaleShift (B h : Mat3) (t : Int) : Mat3 :=
  fun i j => B i j+t*(dInverse B h) i j

def deltaTwiceGamma (B h : Mat3) (dg dh : MetricJet)
    (k i j : Axis) : Int :=
  (dInverse B h) k 0*numerator dg i j 0 +
  (dInverse B h) k 1*numerator dg i j 1 +
  (dInverse B h) k 2*numerator dg i j 2 +
  B k 0*numerator dh i j 0 +
  B k 1*numerator dh i j 1 +
  B k 2*numerator dh i j 2

def secondTwiceGamma (B h : Mat3) (dh : MetricJet)
    (k i j : Axis) : Int :=
  (dInverse B h) k 0*numerator dh i j 0 +
  (dInverse B h) k 1*numerator dh i j 1 +
  (dInverse B h) k 2*numerator dh i j 2

theorem christoffel_polynomial_first_variation
    (B h : Mat3) (dg dh : MetricJet)
    (t : Int) (k i j : Axis) :
    twiceGamma (scaleShift B h t) (shiftJet dg dh t) k i j =
      twiceGamma B dg k i j +
        t*deltaTwiceGamma B h dg dh k i j +
        (t*t)*secondTwiceGamma B h dh k i j := by
  simp only [twiceGamma, scaleShift, shiftJet, deltaTwiceGamma,
    secondTwiceGamma, numerator, Int.mul_add, Int.add_mul,
    Int.mul_sub, Int.sub_mul, Int.mul_assoc]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
  simp only [← Int.mul_assoc]
  omega

#print axioms scale_left
#print axioms adjugate_is_det_inverse
#print axioms determinant_Jacobi_trace
#print axioms volume_density_Jacobi
#print axioms curved_scalar_curvature_differential
#print axioms curved_EH_density_first_variation
#print axioms christoffel_polynomial_first_variation
end CurvedEH010i
