import Init.Data.Rat.Basic
import proofs.FourierTorus010e

/-!
# Minimum Mechanics 010g — Fourier pairing and integration-by-parts

The 010e source represented finite Fourier polynomials as finite lists of
frequency/coefficient monomials. Its zero-mode integral was certified.

This file adds the load-bearing BILINEAR PAIRING
    <f,g> = I(f*g)
at the formal Fourier-polynomial level, and proves its actual integration-
by-parts law for arbitrary finite lists (not only isolated characters).

The derivative E_i acts on e_k as k_i e_k; the angular derivative
∂_i = i E_i is a separate complexification. The zero-mode pairing is an
exact integer read. Formal sums remain syntactic lists, so expressions
equal as Fourier functions can have different list syntax; the pairing
is the declared Reader.

No claim is made about all smooth periodic functions, convergence of
infinite Fourier expansions, the Riemannian volume form, or dynamic gravity.
-/

set_option autoImplicit false

namespace FourierPairing010g
open FourierTorus010e

abbrev opposite (a b : Mode) : Prop :=
  a.kx + b.kx = 0 ∧ a.ky + b.ky = 0 ∧ a.kz + b.kz = 0

def pair (a b : Mode) : Int :=
  if opposite a b then a.c * b.c else 0

def pairOne (a : Mode) (bs : Polynomial) : Int :=
  (bs.map (fun b => pair a b)).sum

def pairing (as bs : Polynomial) : Int :=
  (as.map (fun a => pairOne a bs)).sum

-- A monomial's Fourier frequency matches its partner's inverse exactly
-- when its product contributes to the zero-mode read.
private theorem axis_cases (i : Fin 3) :
    i.val = 0 ∨ i.val = 1 ∨ i.val = 2 := by omega

theorem opposite_symm (a b : Mode) :
    opposite a b ↔ opposite b a := by
  simp only [opposite]
  constructor <;> intro h <;>
    constructor <;> omega

theorem pair_symmetric (a b : Mode) : pair a b = pair b a := by
  change (if opposite a b then a.c * b.c else 0) =
    (if opposite b a then b.c * a.c else 0)
  by_cases h : opposite a b
  · have hb : opposite b a := (opposite_symm a b).mp h
    rw [if_pos h, if_pos hb, Int.mul_comm]
  · have hb : ¬opposite b a := by
      intro hh
      exact h ((opposite_symm a b).mpr hh)
    rw [if_neg h, if_neg hb]

theorem opposite_frequency_sum (i : Fin 3) (a b : Mode)
    (h : opposite a b) : freq i a + freq i b = 0 := by
  have hx := h.1
  have hy := h.2.1
  have hz := h.2.2
  have ih := axis_cases i
  cases ih with
  | inl h0 =>
      simpa [freq, h0] using hx
  | inr hrest =>
      cases hrest with
      | inl h1 =>
          have h0 : i.val ≠ 0 := by omega
          simpa [freq, h0, h1] using hy
      | inr h2 =>
          have h0 : i.val ≠ 0 := by omega
          have h1 : i.val ≠ 1 := by omega
          simpa [freq, h0, h1] using hz

theorem opposite_deriv_left (i : Fin 3) (a b : Mode) :
    opposite (E i a) b ↔ opposite a b := by
  simp [opposite, E]

theorem opposite_deriv_right (i : Fin 3) (a b : Mode) :
    opposite a (E i b) ↔ opposite a b := by
  simp [opposite, E]

-- Pointwise Fourier integration by parts: zero-mode selection makes the
-- sum of the two Euler frequencies vanish. For the physical angular
-- derivative an overall factor i multiplies both terms.
theorem pair_derivative_cancel (i : Fin 3) (a b : Mode) :
    pair (E i a) b + pair a (E i b) = 0 := by
  change
    (if opposite (E i a) b then (E i a).c*b.c else 0) +
    (if opposite a (E i b) then a.c*(E i b).c else 0) = 0
  by_cases h : opposite a b
  · have hsum := opposite_frequency_sum i a b h
    have hl : opposite (E i a) b :=
      (opposite_deriv_left i a b).mpr h
    have hr : opposite a (E i b) :=
      (opposite_deriv_right i a b).mpr h
    rw [if_pos hl, if_pos hr]
    change (freq i a * a.c)*b.c + a.c*(freq i b * b.c)=0
    calc
      (freq i a * a.c) * b.c + a.c * (freq i b * b.c) =
          (freq i a + freq i b) * (a.c * b.c) := by
        rw [Int.add_mul]
        ac_rfl
      _ = 0 := by rw [hsum]; simp
  · have hl : ¬ opposite (E i a) b := by
      intro hh
      exact h ((opposite_deriv_left i a b).mp hh)
    have hr : ¬ opposite a (E i b) := by
      intro hh
      exact h ((opposite_deriv_right i a b).mp hh)
    rw [if_neg hl, if_neg hr]
    decide

theorem pairOne_derivative_cancel (i : Fin 3)
    (a : Mode) (bs : Polynomial) :
    pairOne (E i a) bs +
      pairOne a (derivative i bs) = 0 := by
  induction bs with
  | nil => simp [pairOne, derivative]
  | cons b rest ih =>
      change (pair (E i a) b + pairOne (E i a) rest) +
        (pair a (E i b) + pairOne a (derivative i rest)) = 0
      have hc := pair_derivative_cancel i a b
      omega

-- The actual finite-Fourier IBP identity, summed over BOTH polynomial
-- arguments and for every one of the three coordinate directions.
theorem pairing_integration_by_parts (i : Fin 3)
    (as bs : Polynomial) :
    pairing (derivative i as) bs +
      pairing as (derivative i bs) = 0 := by
  induction as with
  | nil => simp [pairing, derivative]
  | cons a rest ih =>
      change (pairOne (E i a) bs +
        pairing (derivative i rest) bs) +
        (pairOne a (derivative i bs) +
          pairing rest (derivative i bs)) = 0
      have hc := pairOne_derivative_cancel i a bs
      omega

theorem pairing_add_left (as bs cs : Polynomial) :
    pairing (as ++ bs) cs = pairing as cs + pairing bs cs := by
  simp [pairing, List.map_append, List.sum_append]

theorem pairing_add_right (as bs cs : Polynomial) :
    pairing as (bs ++ cs) = pairing as bs + pairing as cs := by
  induction as with
  | nil => simp [pairing]
  | cons a rest ih =>
      change (pairOne a (bs ++ cs) + pairing rest (bs ++ cs)) =
        (pairOne a bs + pairing rest bs) +
        (pairOne a cs + pairing rest cs)
      have ha : pairOne a (bs ++ cs) = pairOne a bs + pairOne a cs := by
        simp [pairOne, List.map_append, List.sum_append]
      rw [ha, ih]
      omega

-- Negative control: coefficient-wise evaluation at the origin includes
-- every character. The integrated bilinear reader retains only matches.
theorem opposite_control :
    pair plusOneX zeroCharacter = 0 ∧
    pair plusOneX ⟨-1,0,0,1⟩ = 1 := by decide

#print axioms pair_derivative_cancel
#print axioms pairOne_derivative_cancel
#print axioms pairing_integration_by_parts
#print axioms pairing_add_left
#print axioms pairing_add_right
#print axioms opposite_control

end FourierPairing010g
