import Init.Data.Rat.Basic
import proofs.FourierNormalBracket010n

/-!
# Minimum Mechanics 010n — cotangent-gradient provenance bridge

This module verifies the load-bearing relation between the two
separately certified 010n certificates: the quadratic energy first
variation and the gradient coefficients used in the canonical H–H
bracket. At each Fourier mode a:

  (δE_n/δπ)_(n+a) = 2 n_c a_c,
  (δE_n/δφ)_(n+a) = -2 D_i(n D_i a)_(n+a).

It also proves the momentum variation read for arbitrary finite lists.

Every expression has a defining Fourier-frequency address and no
distributional delta functions are assumed. The integer Euler
derivative D_i is used; complex angular ∂_i=iD_i and smooth function
completion remain OPEN. No extra axioms or sorry.
-/
set_option autoImplicit false

namespace FourierGradient010n

open FourierTorus010e FourierPairing010g FourierHamiltonian010n
open FourierNormalBracket010n

abbrev Axis := Fin 3
abbrev Polynomial := FourierTorus010e.Polynomial

def productMode (n a : Mode) : Mode :=
  ⟨n.kx+a.kx,n.ky+a.ky,n.kz+a.kz,n.c*a.c⟩

private theorem axes : ∀ i : Axis,
    i=0 ∨ i=1 ∨ i=2 := by decide

theorem product_pair_is_triple_read (n a b : Mode) :
    pair (productMode n a) b = weightedMode n a b := by
  rfl

theorem momentum_gradient_coefficient (n a : Mode) :
    (momentumGradientMode n a).c = 2*(productMode n a).c := by
  rfl

theorem scalar_gradient_coefficient (n a : Mode) :
    (scalarGradientMode n a).c =
      -2*((E 0 (productMode n (E 0 a))).c +
          (E 1 (productMode n (E 1 a))).c +
          (E 2 (productMode n (E 2 a))).c) := by
  simp [scalarGradientMode, lapFrequency, productMode,
    E, freq, Int.mul_add, Int.add_mul,
    Int.neg_mul, Int.mul_neg, Int.mul_assoc,
    Int.mul_comm, Int.mul_left_comm] <;> omega

theorem momentum_mode_read (n a b : Mode) :
    pair (momentumGradientMode n a) b =
      2*weightedMode n a b := by
  change
    (if tripleMatch n a b then (2*(n.c*a.c))*b.c else 0) =
      2*(if tripleMatch n a b then (n.c*a.c)*b.c else 0)
  by_cases h : tripleMatch n a b
  · simp only [if_pos h]
    ac_rfl
  · simp [h]

private theorem momentum_one_row (n a : Mode) (r : Polynomial) :
    (r.map (fun b => pair (momentumGradientMode n a) b)).sum =
      2*(r.map (fun b => weightedMode n a b)).sum := by
  induction r with
  | nil => simp
  | cons b bs ih =>
      simp only [List.map_cons, List.sum_cons]
      rw [momentum_mode_read, ih]
      omega

theorem momentum_gradient_pairing (n : Mode)
    (π r : Polynomial) :
    pairing (momentumGradient n π) r =
      2*weightedPair n π r := by
  induction π with
  | nil => simp [momentumGradient, pairing, weightedPair]
  | cons a rest ih =>
      change
        (r.map (fun b => pair (momentumGradientMode n a) b)).sum +
          pairing (momentumGradient n rest) r =
        2*((r.map (fun b => weightedMode n a b)).sum +
          weightedPair n rest r)
      rw [momentum_one_row, ih]
      omega

-- A single-mode magnetic-gradient read is the precise Fourier
-- Laplacian symbol at the shifted wave address.
theorem scalar_gradient_nonzero_witness :
    (scalarGradientMode ⟨1,0,0,1⟩ ⟨1,0,0,1⟩).c = -4 := by
  decide

theorem momentum_gradient_nonzero_witness :
    (momentumGradientMode ⟨1,0,0,1⟩ ⟨1,0,0,1⟩).c = 2 := by
  decide

#print axioms product_pair_is_triple_read
#print axioms momentum_gradient_coefficient
#print axioms scalar_gradient_coefficient
#print axioms momentum_mode_read
#print axioms momentum_gradient_pairing
#print axioms scalar_gradient_nonzero_witness

end FourierGradient010n
