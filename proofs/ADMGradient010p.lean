import Init.Data.Rat.Basic
import proofs.MetricShift010p
import proofs.Maxwell010b

/-!
# Minimum Mechanics 010p — full local ADM Einstein–Maxwell normal gradients

010o's sourceNormalGradient is still an OPEN smooth-functional bridge.
This module proves its NONCIRCULAR pointwise algebra for arbitrary
nonorthonormal invertible spatial metric g and inverse B:

* The metric gradient of H[N] is N U + C(Hess N). U is the full
  ultralocal gravitational+Maxwell metric response, and the Hessian
  C is the certified geometric curvature variation from 010c/010j.
* The momentum gradient is N K, where K=2gPg-g tr(gP), derived from
  the DeWitt quadratic and retained with the physical reciprocal
  normalization ab=1.
* The SINGLE gravitational canonical PB, built by matrix trace
  contractions, annihilates ALL U terms for arbitrary N,M and
  reduces precisely to the covariant Hessian current.
* The inherited Maxwell true gradient bracket supplies the EM
  momentum flux and preserves μ0 normalization.
* Their sum reduces to one local Einstein-Maxwell normal-current reader.

This is a finite-point jet identity. The input U has an independently
defined physical formula but is arbitrary here precisely because all
ultralocal contributions cancel; no curvature-equation hypothesis is
needed. Differentiability of the actual smooth Einstein-Maxwell action
and its integrated momentum-generator identification remain OPEN.

No new axioms, no sorry, no Mathlib. Lean 4.33.0.
-/

set_option autoImplicit false
namespace ADMGradient010p

open MetricInverse010i DeWittCovariant010p
abbrev M := MetricInverse010i.Mat3

def metricGradient (B U : M) (n : Int) (h : M) : M :=
  add (scale n U) (hessianGradient B h)

def momentumGradient (g P : M) (n : Int) : M :=
  scale n (kineticGradient g P)

def canonicalGravityPB (g B P U HN HM : M) (n m : Int) : Int :=
  tr (mul (metricGradient B U n HN) (momentumGradient g P m)) -
  tr (mul (momentumGradient g P n) (metricGradient B U m HM))

def covariantHessianFlux (P HN HM : M) (n m : Int) : Int :=
  2*(n*tr (mul P HM)-m*tr (mul P HN))

theorem gravity_gradients_expand (K CN CM U : M) (n m : Int) :
    tr (mul (add (scale n U) CN) (scale m K)) -
    tr (mul (scale n K) (add (scale m U) CM)) =
      m*tr (mul CN K)-n*tr (mul K CM) := by
  have h1 :
      tr (mul (add (scale n U) CN) (scale m K)) =
        n*m*tr (mul U K)+m*tr (mul CN K) := by
    simp only [MetricInverse010i.add_mul, mul_scale_left,
      mul_scale_right, trace_add, trace_scale,
      Int.mul_add, Int.mul_assoc] <;> ac_rfl
  have h2 :
      tr (mul (scale n K) (add (scale m U) CM)) =
        n*m*tr (mul K U)+n*tr (mul K CM) := by
    simp only [MetricInverse010i.mul_add, mul_scale_left,
      mul_scale_right, trace_add, trace_scale,
      Int.mul_add, Int.mul_assoc] <;> ac_rfl
  rw [h1,h2, tr_mul_comm U K]
  omega

-- No scalar ultralocal metric response U survives. This includes
-- the gravity-metric response and Maxwell stress-energy variation.
theorem gravity_normal_normal_covariant
    (g B P U HN HM : M) (n m : Int)
    (hgB : mul g B = M1) (hBg : mul B g = M1) :
    canonicalGravityPB g B P U HN HM n m =
      covariantHessianFlux P HN HM n m := by
  simp only [canonicalGravityPB, metricGradient,
    momentumGradient, covariantHessianFlux]
  rw [gravity_gradients_expand
        (kineticGradient g P) (hessianGradient B HN)
        (hessianGradient B HM) U n m]
  rw [tr_mul_comm (hessianGradient B HN) (kineticGradient g P)]
  rw [covariant_dewitt_hessian g B P HN hgB hBg,
      covariant_dewitt_hessian g B P HM hgB hBg]
  simp only [Int.mul_neg, Int.neg_mul, Int.mul_sub,
    Int.sub_mul, Int.mul_assoc]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
  omega

def maxwellCellsPB (es : List Maxwell010b.Cell) : Int :=
  (es.map Maxwell010b.cellPoisson).sum

def maxwellCellsFlux (es : List Maxwell010b.Cell) : Int :=
  (es.map Maxwell010b.cellFlux).sum

def combinedLocalPB (g B P U HN HM : M)
    (n m : Int) (es : List Maxwell010b.Cell) : Int :=
  canonicalGravityPB g B P U HN HM n m + maxwellCellsPB es

def combinedLocalCurrent (P HN HM : M)
    (n m : Int) (es : List Maxwell010b.Cell) : Int :=
  covariantHessianFlux P HN HM n m + maxwellCellsFlux es

theorem nonorthonormal_einstein_maxwell_gradient
    (g B P U HN HM : M) (n m : Int)
    (es : List Maxwell010b.Cell)
    (hgB : mul g B = M1) (hBg : mul B g = M1) :
    combinedLocalPB g B P U HN HM n m es =
      combinedLocalCurrent P HN HM n m es := by
  simp only [combinedLocalPB, combinedLocalCurrent]
  rw [gravity_normal_normal_covariant g B P U HN HM n m hgB hBg]
  simp only [maxwellCellsPB, maxwellCellsFlux]
  exact congrArg (fun v : Int => covariantHessianFlux P HN HM n m + v)
    (Maxwell010b.maxwell_normal_normal_finite_sum es)

-- Finite lists of independently addressed jets can have a different
-- metric at every address; their algebraic PB-current equality holds.
structure Address where
  g : M
  B : M
  P : M
  U : M
  HN : M
  HM : M
  n : Int
  m : Int
  es : List Maxwell010b.Cell
  hRight : mul g B = M1
  hLeft : mul B g = M1

def addressPB (x : Address) : Int :=
  combinedLocalPB x.g x.B x.P x.U x.HN x.HM x.n x.m x.es

def addressCurrent (x : Address) : Int :=
  combinedLocalCurrent x.P x.HN x.HM x.n x.m x.es

theorem address_local_pb_matches_current (x : Address) :
    addressPB x = addressCurrent x := by
  exact nonorthonormal_einstein_maxwell_gradient
    x.g x.B x.P x.U x.HN x.HM x.n x.m x.es x.hRight x.hLeft

theorem finite_address_sum_current (xs : List Address) :
    (xs.map addressPB).sum = (xs.map addressCurrent).sum := by
  induction xs with
  | nil => rfl
  | cons a rest ih =>
      simp only [List.map_cons, List.sum_cons]
      rw [address_local_pb_matches_current a, ih]

#print axioms gravity_gradients_expand
#print axioms gravity_normal_normal_covariant
#print axioms nonorthonormal_einstein_maxwell_gradient
#print axioms address_local_pb_matches_current
#print axioms finite_address_sum_current

end ADMGradient010p
