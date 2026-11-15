import Init.Data.Rat.Basic
import proofs.JetStokes010e

/-!
# Minimum Mechanics 010e — finite Fourier mode (algebraic T³) bridge

A character on a three-torus is e_k(θ) = exp(i k·θ), k ∈ ℤ³.
This file represents a finite formal sum of characters as a List of Modes,
with integer coefficients. E_j(e_k) := k_j e_k is the Euler derivative;
the actual angular derivative is i E_j after complexification. The
normalized torus integral extracts the zero Fourier coefficient.

Exactly proved:
* each mode's Euler derivative obeys the multiplicative Leibniz law;
* the integral of E_j is zero on every mode and every finite sum;
* a nonzero-character witness has nonzero derivative and zero integral;
* a negative control shows evaluation at a point is not the Haar read.

The map from this formal algebra to actual smooth periodic complex-valued
functions and the general C∞ integration theory are not formalized here.
The representation is unnormalized syntax: different lists can represent
the same Fourier polynomial. Thus the 010d StokesSlice is instantiated by
the separate jet-algebra file; this file supplies a genuine finite-mode
periodic analogue, not a claimed full smooth-manifold instance.

No sorry, axioms, Mathlib, or analytic coercions are introduced.
-/

set_option autoImplicit false

namespace FourierTorus010e

structure Mode where
  kx : Int
  ky : Int
  kz : Int
  c : Int
  deriving DecidableEq, Repr

def product (a b : Mode) : Mode :=
  ⟨a.kx+b.kx, a.ky+b.ky, a.kz+b.kz, a.c*b.c⟩

def freq (i : Fin 3) (a : Mode) : Int :=
  if i.val = 0 then a.kx
  else if i.val = 1 then a.ky
  else a.kz

def E (i : Fin 3) (a : Mode) : Mode :=
  ⟨a.kx, a.ky, a.kz, (freq i a)*a.c⟩

def zeroFreq (a : Mode) : Prop :=
  a.kx = 0 ∧ a.ky = 0 ∧ a.kz = 0

def residue (a : Mode) : Int :=
  if zeroFreq a then a.c else 0

private theorem axis_cases (i : Fin 3) :
    i.val = 0 ∨ i.val = 1 ∨ i.val = 2 := by omega

theorem freq_product (i : Fin 3) (a b : Mode) :
    freq i (product a b) = freq i a + freq i b := by
  have h := axis_cases i
  cases h with
  | inl h0 => simp [freq, product, h0]
  | inr h =>
    cases h with
    | inl h1 =>
      have h0 : i.val ≠ 0 := by omega
      simp [freq, product, h0, h1]
    | inr h2 =>
      have h0 : i.val ≠ 0 := by omega
      have h1 : i.val ≠ 1 := by omega
      simp [freq, product, h0, h1]

theorem freq_of_zero (i : Fin 3) (a : Mode)
    (hz : zeroFreq a) : freq i a = 0 := by
  have h := axis_cases i
  cases h with
  | inl h0 =>
    simp [freq, h0, zeroFreq] at *
  | inr h =>
    cases h with
    | inl h1 =>
      have h0 : i.val ≠ 0 := by omega
      simp [freq, h0, h1, zeroFreq] at *
    | inr h2 =>
      have h0 : i.val ≠ 0 := by omega
      have h1 : i.val ≠ 1 := by omega
      simp [freq, h0, h1, zeroFreq] at *

theorem monomial_Leibniz (i : Fin 3) (a b : Mode) :
    (E i (product a b)).c =
    (product (E i a) b).c + (product a (E i b)).c := by
  simp only [E, product]
  rw [freq_product, Int.add_mul]
  ac_rfl

theorem residue_E_zero (i : Fin 3) (a : Mode) :
    residue (E i a) = 0 := by
  by_cases hz : zeroFreq a
  · have hi : freq i a = 0 := freq_of_zero i a hz
    simp [residue, E, zeroFreq, hz, hi]
  · simp [residue, E, zeroFreq, hz]

abbrev Polynomial := List Mode

def derivative (i : Fin 3) (f : Polynomial) : Polynomial :=
  f.map (E i)

def integral (f : Polynomial) : Int :=
  (f.map residue).sum

theorem stokes_finite_Fourier (i : Fin 3) (f : Polynomial) :
    integral (derivative i f) = 0 := by
  induction f with
  | nil => decide
  | cons a rest ih =>
      simp only [integral, derivative, List.map_cons, List.sum_cons] at ih ⊢
      rw [residue_E_zero i a]
      simpa using ih

theorem integral_empty : integral [] = 0 := by decide

theorem integral_add (f g : Polynomial) :
    integral (f ++ g) = integral f + integral g := by
  simp [integral, List.map_append, List.sum_append]

def plusOneX : Mode := ⟨1,0,0,1⟩
def zeroCharacter : Mode := ⟨0,0,0,1⟩

theorem nontrivial_mode_derivative : E 0 plusOneX = plusOneX := by decide
theorem nonzero_mode_derivative : E 0 plusOneX ≠ ⟨0,0,0,0⟩ := by decide
theorem haar_character_zero : residue plusOneX = 0 := by decide
theorem haar_constant_one : residue zeroCharacter = 1 := by decide

-- A naive evaluation-at-θ=0 returns 1 on e_x, unlike the Haar integral.
theorem wrong_point_read_negative_control :
    plusOneX.c ≠ residue plusOneX := by decide

#print axioms freq_product
#print axioms monomial_Leibniz
#print axioms residue_E_zero
#print axioms stokes_finite_Fourier
#print axioms integral_add
#print axioms nontrivial_mode_derivative
#print axioms wrong_point_read_negative_control

end FourierTorus010e
