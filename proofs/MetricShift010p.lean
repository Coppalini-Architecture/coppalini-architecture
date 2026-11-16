import Init.Data.Rat.Basic
import proofs.DeWittCovariant010p

/-!
# Minimum Mechanics 010p — metric-dependent ADM momentum shift

Target from 010o:
  w^i = g^{ij}(N∂_j M - M∂_j N)
  C_i = -2g_{ik}D_j π^{jk} + F_{ij} E^j.

Here g and B are arbitrary 3×3 integer matrices with gB=I, and g is
symmetric. All three derivatives of lapse, all components of the
momentum-density divergence and all Maxwell curvature components are
retained. The theorem proves directly:
  w^i C_i =
    -2(N∂_k M - M∂_k N)D_jπ^{jk}
       + w^i F_ij E^j.

This connects the gradient-current read to the *same metric-dependent
shift* used in the canonical diffeomorphism generator. No separate
shift field or free source-current address is introduced.

The proof is a pointwise exact tensor-contraction identity; it does
not certify the integrated smooth-boundary functional differentiability
or show that a suture map is symplectic. Those remain OPEN.

No new axioms/sorry/Mathlib; Lean 4.33.0.
-/
set_option autoImplicit false
namespace MetricShift010p

open MetricInverse010i DeWittCovariant010p
abbrev A := Fin 3
abbrev M := MetricInverse010i.Mat3
abbrev Vec := A → Int

def sum3 (f : A → Int) : Int := f 0+f 1+f 2
def vecMul (B : M) (w : Vec) (i : A) : Int :=
  sum3 (fun j => B i j*w j)

def covCurrent (N M0 : Int) (dN dM : Vec) (j : A) : Int :=
  N*dM j-M0*dN j

def raisedShift (B : M) (N M0 : Int) (dN dM : Vec) : Vec :=
  vecMul B (covCurrent N M0 dN dM)

def loweredRaised (g B : M) (w : Vec) (k : A) : Int :=
  sum3 (fun i => (vecMul B w i)*g i k)

private theorem axis_cases : ∀ i : A, i=0 ∨ i=1 ∨ i=2 := by decide

theorem lowered_raised_equals_product
    (g B : M) (w : Vec) (k : A)
    (hg : ∀ i j, g i j = g j i) :
    loweredRaised g B w k = vecMul (mul g B) w k := by
  have h0 := hg 0 k
  have h1 := hg 1 k
  have h2 := hg 2 k
  simp only [loweredRaised, vecMul, sum3, mul]
  rw [h0, h1, h2]
  simp only [Int.mul_add, Int.add_mul, Int.mul_assoc]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
  omega

theorem vecMul_identity (w : Vec) (k : A) :
    vecMul M1 w k = w k := by
  rcases axis_cases k with hk | hk | hk <;>
    subst k <;> simp [vecMul, sum3, M1]

theorem lower_after_raise
    (g B : M) (w : Vec) (k : A)
    (hg : ∀ i j, g i j=g j i)
    (hgB : mul g B = M1) :
    loweredRaised g B w k = w k := by
  rw [lowered_raised_equals_product g B w k hg, hgB]
  exact vecMul_identity w k

def gravCovMomentum (g : M) (divPi : Vec) (i : A) : Int :=
  -2*sum3 (fun k => g i k*divPi k)

def emCovMomentum (F : M) (E : Vec) (i : A) : Int :=
  sum3 (fun j => F i j*E j)

def fullCovMomentum (g F : M) (divPi E : Vec) (i : A) : Int :=
  gravCovMomentum g divPi i + emCovMomentum F E i

def gravityShiftSmeared (g B : M) (w divPi : Vec) : Int :=
  sum3 (fun i => vecMul B w i * gravCovMomentum g divPi i)

def lowerGravityCurrent (w divPi : Vec) : Int :=
  -2*sum3 (fun k => w k*divPi k)

theorem gravityShift_interchange
    (g B : M) (w divPi : Vec) :
    gravityShiftSmeared g B w divPi =
      -2*sum3 (fun k => loweredRaised g B w k*divPi k) := by
  simp only [gravityShiftSmeared, gravCovMomentum,
    loweredRaised, vecMul, sum3]
  simp only [Int.mul_add, Int.add_mul, Int.mul_assoc]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
  simp only [← Int.mul_assoc]
  omega

theorem gravity_shift_metric_address
    (g B : M) (w divPi : Vec)
    (hg : ∀ i j, g i j=g j i)
    (hgB : mul g B = M1) :
    gravityShiftSmeared g B w divPi =
      lowerGravityCurrent w divPi := by
  rw [gravityShift_interchange]
  simp only [lowerGravityCurrent, sum3]
  rw [lower_after_raise g B w 0 hg hgB,
      lower_after_raise g B w 1 hg hgB,
      lower_after_raise g B w 2 hg hgB]

def emShiftSmeared (B F : M) (w E : Vec) : Int :=
  sum3 (fun i => vecMul B w i * emCovMomentum F E i)

def combinedShiftSmeared (g B F : M)
    (w divPi E : Vec) : Int :=
  sum3 (fun i => vecMul B w i * fullCovMomentum g F divPi E i)

theorem combinedShift_expands (g B F : M)
    (w divPi E : Vec) :
    combinedShiftSmeared g B F w divPi E =
      gravityShiftSmeared g B w divPi +
      emShiftSmeared B F w E := by
  simp only [combinedShiftSmeared, gravityShiftSmeared,
    emShiftSmeared, fullCovMomentum, sum3]
  simp only [Int.mul_add]
  omega

theorem same_metric_shift_sources
    (g B F : M) (w divPi E : Vec)
    (hg : ∀ i j, g i j=g j i)
    (hgB : mul g B = M1) :
    combinedShiftSmeared g B F w divPi E =
      lowerGravityCurrent w divPi +
      emShiftSmeared B F w E := by
  rw [combinedShift_expands,
      gravity_shift_metric_address g B w divPi hg hgB]

theorem gauss_improved_presentation
    (g B F : M) (w divPi E : Vec) (gaugeCorrection : Int) :
    combinedShiftSmeared g B F w divPi E =
      (combinedShiftSmeared g B F w divPi E + gaugeCorrection) -
        gaugeCorrection := by omega

-- A nonorthonormal positive-definite metric with integer inverse,
-- lifted directly from the certified 010k witness.
def nonorthogonalG : M := MetricVolume010k.sampleG
def nonorthogonalB : M := MetricVolume010k.sampleB

theorem metric_witness_symmetric :
    ∀ i j : A, nonorthogonalG i j = nonorthogonalG j i := by
  intro i j
  rcases axis_cases i with hi | hi | hi <;>
    rcases axis_cases j with hj | hj | hj <;>
    subst i <;> subst j <;> decide

theorem nonorthogonal_shift_restores_lower
    (w : Vec) (k : A) :
    loweredRaised nonorthogonalG nonorthogonalB w k = w k := by
  exact lower_after_raise nonorthogonalG nonorthogonalB w k
    metric_witness_symmetric
    MetricVolume010k.sample_metric_invertible.1

#print axioms lowered_raised_equals_product
#print axioms lower_after_raise
#print axioms gravityShift_interchange
#print axioms gravity_shift_metric_address
#print axioms combinedShift_expands
#print axioms same_metric_shift_sources
#print axioms gauss_improved_presentation
#print axioms nonorthogonal_shift_restores_lower

end MetricShift010p
