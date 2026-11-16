import Init.Data.Rat.Basic
import proofs.ConnectionPalatini010h
import proofs.FourierPairing010g

/-!
# Minimum Mechanics 010h — flat 3D Einstein–Hilbert curvature variation

Reference: SD.22–SD.27, in the fixed 010a–010g lineage.

This file specializes the connection Palatini identity to the flat
metric gamma_ij = delta_ij. Every H(a,b,i,j) encodes a symmetric second
derivative ∂_a ∂_b h_ij, including both symmetries
(∂_a∂_b = ∂_b∂_a, h_ij = h_ji), as a 6×6 independent integer ledger.

Exact theorem:
  δR = ∂_i∂_j h_ij - Δ tr h,
proved by tracing the 2δΓ formula through the linearized Ricci tensor.
The factor 2 is retained throughout to keep integer-only arithmetic.

The 010g Fourier pairing additionally provides two integrations by parts,
giving the derivative-bearing term in the EH first variation on a flat
periodic slice. Metric inverse/volume variation, curved backgrounds and
nonlinear Einstein–Hilbert function-space differentiability remain OPEN.
-/

set_option autoImplicit false

namespace FlatEH010h

abbrev Axis := Fin 3
abbrev SymAddress := Fin 6
abbrev Hessian := SymAddress → SymAddress → Int

def pairIndex (i j : Axis) : SymAddress :=
  match i.val, j.val with
  | 0, 0 => 0
  | 1, 1 => 1
  | 2, 2 => 2
  | 0, 1 => 3
  | 1, 0 => 3
  | 0, 2 => 4
  | 2, 0 => 4
  | 1, 2 => 5
  | 2, 1 => 5
  | _, _ => 0

theorem pairIndex_symmetry :
    ∀ i j : Axis, pairIndex i j = pairIndex j i := by decide

-- First address = derivative pair; second address = metric pair.
def H (h : Hessian) (a b i j : Axis) : Int :=
  h (pairIndex a b) (pairIndex i j)

theorem H_derivative_symmetry (h : Hessian)
    (a b i j : Axis) : H h a b i j = H h b a i j := by
  simp only [H]
  rw [pairIndex_symmetry a b]

theorem H_metric_symmetry (h : Hessian)
    (a b i j : Axis) : H h a b i j = H h a b j i := by
  simp only [H]
  rw [pairIndex_symmetry i j]

def sum3 (f : Axis → Int) : Int := f 0 + f 1 + f 2

-- 2 ∂_a δΓ^k_ij =
--   ∂_a∂_i h_jk + ∂_a∂_j h_ik - ∂_a∂_k h_ij.
def twoDGamma (h : Hessian) (a k i j : Axis) : Int :=
  H h a i j k + H h a j i k - H h a k i j

-- 2 δR_ij = 2(∂_k δΓ^k_ij - ∂_j δΓ^k_ik)
def twoRicci (h : Hessian) (i j : Axis) : Int :=
  sum3 (fun k => twoDGamma h k k i j -
                  twoDGamma h j k i k)

def twoScalar (h : Hessian) : Int :=
  sum3 (fun i => twoRicci h i i)

def divDiv (h : Hessian) : Int :=
  sum3 (fun i => sum3 (fun j => H h i j i j))

def lapTrace (h : Hessian) : Int :=
  sum3 (fun i => sum3 (fun j => H h i i j j))

-- Fully linear in 36 independent symmetric Hessian slots:
-- every cancellation is certified for all integer values.
theorem flat_scalar_curvature_first_variation (h : Hessian) :
    twoScalar h = 2 * (divDiv h - lapTrace h) := by
  simp only [twoScalar, twoRicci, twoDGamma, divDiv, lapTrace,
    sum3, H]
  simp [pairIndex]
  omega

-- The correct linearized Ricci tensor is symmetric at this flat address.
theorem flat_ricci_symmetry (h : Hessian) (i j : Axis) :
    twoRicci h i j = twoRicci h j i := by
  have hi : i = 0 ∨ i = 1 ∨ i = 2 := by decide
  have hj : j = 0 ∨ j = 1 ∨ j = 2 := by decide
  rcases hi with rfl | rfl | rfl <;>
    rcases hj with rfl | rfl | rfl <;>
    simp [twoRicci, twoDGamma, sum3, H, pairIndex] <;> omega

-- The value of the flat background curvature vanishes;
-- therefore the linear contribution of sqrt(det g) to sqrt(g)R is 0
-- at this background (its scalar-curvature factor is zero).
theorem flat_volume_cross_zero (dVolume R0 : Int) (hR0 : R0 = 0) :
    dVolume * R0 = 0 := by
  rw [hR0]
  simp

/-! ## Fourier-pairing realization of the Hessian transfer -/

open FourierTorus010e FourierPairing010g

theorem fourier_two_ibp (i j : Axis)
    (N h : Polynomial) :
    pairing N (derivative i (derivative j h)) =
      pairing (derivative j (derivative i N)) h := by
  have h1 := pairing_integration_by_parts i N (derivative j h)
  have h2 := pairing_integration_by_parts j (derivative i N) h
  omega

-- This is the derivative-bearing part of the first variation of
-- -b∫N sqrt(g) R at g=identity. The complete nonlinear functional
-- variation requires independently certified Levi-Civita geometry.
theorem flat_EH_hessian_sign (i j : Axis) (N h : Polynomial) :
    -(pairing N (derivative i (derivative j h))) =
      -(pairing (derivative j (derivative i N)) h) := by
  rw [fourier_two_ibp i j N h]

#print axioms pairIndex_symmetry
#print axioms H_derivative_symmetry
#print axioms H_metric_symmetry
#print axioms flat_scalar_curvature_first_variation
#print axioms flat_ricci_symmetry
#print axioms fourier_two_ibp
#print axioms flat_EH_hessian_sign

end FlatEH010h
