import Init.Data.Rat.Basic
import proofs.CurvedEHVariation010j

/-!
# Minimum Mechanics 010k — volume compatibility from the metric determinant

JURISDICTION
Fixed inputs 010a–010j, unchanged.  This is one spatial-direction
coordinate jet on a 3-dimensional invertible metric.  It constructs the
metric-compatible derivative ∂_a g = Γ_aᵀ g + g Γ_a, and proves
  tr(g⁻¹ ∂_a g) = 2 tr(Γ_a)
  ∂_a det(g) = 2 det(g) tr(Γ_a).
For a supplied square-root volume witness v²=det(g), the exact
denominator-free formula is
  2 v ∂_a v = 2 v² tr(Γ_a).
This identifies the volume-compatibility seam with the same connection
trace used by the certified 010j contracted Palatini divergence.

This is a local algebraic differential of metric matrices.  A global
positive volume form and existence of its smooth square root on a
specific spatial manifold remain OPEN.  No new axioms or sorry.
-/

set_option autoImplicit false
namespace MetricVolume010k

open MetricInverse010i MetricDeterminant010i CurvedEH010i

abbrev Mat3 := MetricInverse010i.Mat3
abbrev Axis := Fin 3

def trans (A : Mat3) : Mat3 := fun i j => A j i

def traceMat (A : Mat3) : Int := A 0 0 + A 1 1 + A 2 2

theorem traceMul_eq_traceProduct (A B : Mat3) :
    traceMat (mul A B) = traceProduct A B := by
  rfl

theorem trace_mul_comm (A B : Mat3) :
    traceMat (mul A B) = traceMat (mul B A) := by
  simp only [traceMat, mul]
  ac_rfl

theorem traceMat_add (A B : Mat3) :
    traceMat (add A B) = traceMat A + traceMat B := by
  simp only [traceMat, add]
  omega

theorem traceMat_trans (A : Mat3) :
    traceMat (trans A) = traceMat A := rfl

-- The covariant-derivative metric-compatibility equation, with one
-- connection matrix Γ_a^i_j per spatial address a.
def compatibleDG (g Gamma : Mat3) : Mat3 :=
  add (mul (trans Gamma) g) (mul g Gamma)

def connTrace (Gamma : Mat3) : Int := traceMat Gamma

theorem inverse_metric_contracts_compatible_derivative
    (g B Gamma : Mat3)
    (hRight : mul g B = M1) (hLeft : mul B g = M1) :
    traceProduct B (compatibleDG g Gamma) =
      connTrace Gamma + connTrace Gamma := by
  have hA : traceMat (mul B (mul (trans Gamma) g)) =
      traceMat Gamma := by
    calc
      traceMat (mul B (mul (trans Gamma) g)) =
          traceMat (mul (mul B (trans Gamma)) g) := by rw [mul_assoc]
      _ = traceMat (mul g (mul B (trans Gamma))) :=
          trace_mul_comm _ _
      _ = traceMat (mul (mul g B) (trans Gamma)) := by rw [mul_assoc]
      _ = traceMat (trans Gamma) := by rw [hRight, one_mul]
      _ = traceMat Gamma := traceMat_trans Gamma
  have hB : traceMat (mul B (mul g Gamma)) =
      traceMat Gamma := by
    calc
      traceMat (mul B (mul g Gamma)) =
          traceMat (mul (mul B g) Gamma) := by rw [mul_assoc]
      _ = traceMat Gamma := by rw [hLeft, one_mul]
  calc
    traceProduct B (compatibleDG g Gamma) =
        traceMat (mul B (compatibleDG g Gamma)) :=
          (traceMul_eq_traceProduct _ _).symm
    _ = traceMat (mul B (mul (trans Gamma) g)) +
          traceMat (mul B (mul g Gamma)) := by
      rw [compatibleDG, mul_add, traceMat_add]
    _ = connTrace Gamma + connTrace Gamma := by
      rw [hA, hB]
      rfl

theorem determinant_metric_compatibility
    (g B Gamma : Mat3)
    (hRight : mul g B = M1) (hLeft : mul B g = M1) :
    deltaDet g (compatibleDG g Gamma) =
      determinant g * (connTrace Gamma + connTrace Gamma) := by
  rw [determinant_Jacobi_trace g B (compatibleDG g Gamma) hRight]
  rw [inverse_metric_contracts_compatible_derivative g B Gamma hRight hLeft]

-- Retain the exact square-root normalization from 010i.
theorem volume_compatibility_denominator_free
    (g B Gamma : Mat3)
    (hRight : mul g B = M1) (hLeft : mul B g = M1)
    (r : VolumeRoot g (compatibleDG g Gamma)) :
    r.v * r.dv + r.v * r.dv =
      (r.v * r.v) * (connTrace Gamma + connTrace Gamma) := by
  rw [r.firstOrderSquare]
  rw [determinant_metric_compatibility g B Gamma hRight hLeft]
  rw [r.square]

-- Nontrivial positive-definite unimodular matrix and integer inverse,
-- showing the formula is not limited to identity coordinates.
def sampleG : Mat3 :=
  fun i j =>
    if i=0 ∧ j=0 then 2
    else if i=0 ∧ j=1 then 1
    else if i=1 ∧ j=0 then 1
    else if i=j then 1 else 0

def sampleB : Mat3 :=
  fun i j =>
    if i=0 ∧ j=0 then 1
    else if i=0 ∧ j=1 then -1
    else if i=1 ∧ j=0 then -1
    else if i=1 ∧ j=1 then 2
    else if i=2 ∧ j=2 then 1 else 0

def sampleGamma : Mat3 :=
  fun i j => if i=0 ∧ j=0 then 1 else 0

theorem sample_metric_invertible :
    mul sampleG sampleB = M1 ∧
    mul sampleB sampleG = M1 ∧
    determinant sampleG = 1 := by decide

theorem sample_volume_response :
    deltaDet sampleG (compatibleDG sampleG sampleGamma) = 2 ∧
    connTrace sampleGamma = 1 := by decide

#print axioms trace_mul_comm
#print axioms traceMat_add
#print axioms inverse_metric_contracts_compatible_derivative
#print axioms determinant_metric_compatibility
#print axioms volume_compatibility_denominator_free
#print axioms sample_metric_invertible
#print axioms sample_volume_response

end MetricVolume010k
