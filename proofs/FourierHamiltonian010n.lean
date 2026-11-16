import Init.Data.Rat.Basic
import proofs.FourierCanonical010n

/-!
# Minimum Mechanics 010n — smeared quadratic Fourier-field energy variation

This is the next layer after the certified 010n canonical zero-mode
Poisson bracket. The source, normalization and claims of 010a–010m
remain unchanged.

For a SINGLE finite Fourier lapse character n and arbitrary finite
Fourier-polynomial scalar fields φ,π, define an exact triple product read
  W_n(f,g) = (n f g)_0
           = Σ_(n+k+l=0) n_n f_k g_l.
The Euler derivatives are D_i e_k = k_i e_k.

The formal quadratic scalar energy is
  E_n(φ,π) = W_n(π,π) + Σ_i W_n(D_i φ,D_i φ).
Its first variation is DERIVED from the quadratic polynomial:
  E_n(φ+h,π+r) = E_n(φ,π)
       + 2(W_n(π,r)+Σ_i W_n(D_iφ,D_i h)) + E_n(h,r).

The local Fourier zero-mode Stokes identity then gives the derivative-
bearing adjoint, with the lapse derivative explicitly retained:
  W_n(D_iφ,D_i h)
   = -W_(D_i n)(D_iφ,h) - W_n(D_iD_iφ,h).
These are genuine variations of a defined finite-support functional;
no freely assigned first derivative is used.

The physical angular derivative ∂_i=iD_i requires complexification,
and the standard Hamiltonian includes a 1/2 and physical metric weights.
The present energy is the explicit integer Euler algebra version.
Smooth infinite Fourier completion, canonical gradients as continuous
cotangent vectors and full ADM Dirac first-class brackets remain OPEN.

Lean 4.33.0, no Mathlib, no sorry and no additional axioms.
-/
set_option autoImplicit false
namespace FourierHamiltonian010n

open FourierTorus010e FourierPairing010g FourierCanonical010n

abbrev Polynomial := FourierTorus010e.Polynomial
abbrev Axis := Fin 3

abbrev tripleMatch (n a b : Mode) : Prop :=
  n.kx+a.kx+b.kx=0 ∧
  n.ky+a.ky+b.ky=0 ∧
  n.kz+a.kz+b.kz=0

def weightedMode (n a b : Mode) : Int :=
  if tripleMatch n a b then (n.c*a.c)*b.c else 0

def weightedOne (n a : Mode) (bs : Polynomial) : Int :=
  (bs.map (fun b => weightedMode n a b)).sum

def weightedPair (n : Mode) (as bs : Polynomial) : Int :=
  (as.map (fun a => weightedOne n a bs)).sum

private theorem axis_cases : ∀ i : Axis,
    i=0 ∨ i=1 ∨ i=2 := by decide

theorem triple_match_swap (n a b : Mode) :
    tripleMatch n a b ↔ tripleMatch n b a := by
  constructor
  · intro h
    exact ⟨by omega, by omega, by omega⟩
  · intro h
    exact ⟨by omega, by omega, by omega⟩

theorem weighted_mode_swap (n a b : Mode) :
    weightedMode n a b = weightedMode n b a := by
  change
    (if tripleMatch n a b then (n.c*a.c)*b.c else 0) =
    (if tripleMatch n b a then (n.c*b.c)*a.c else 0)
  by_cases h : tripleMatch n a b
  · have hs := (triple_match_swap n a b).mp h
    rw [if_pos h, if_pos hs]
    ac_rfl
  · have hs : ¬tripleMatch n b a := by
      intro hh
      exact h ((triple_match_swap n a b).mpr hh)
    rw [if_neg h, if_neg hs]

private theorem sum_map_add {α : Type} (xs : List α)
    (f g : α → Int) :
    (xs.map (fun x => f x + g x)).sum =
      (xs.map f).sum + (xs.map g).sum := by
  induction xs with
  | nil => simp
  | cons a rest ih =>
      simp only [List.map_cons, List.sum_cons]
      omega

private theorem map_zero_sum {α : Type} (ys : List α) :
    (ys.map (fun _ => (0 : Int))).sum = 0 := by
  induction ys with
  | nil => rfl
  | cons b rest ih =>
      simp only [List.map_cons, List.sum_cons, ih]
      omega

private theorem double_sum_swap {α β : Type}
    (xs : List α) (ys : List β) (f : α → β → Int) :
    (xs.map (fun a => (ys.map (fun b => f a b)).sum)).sum =
      (ys.map (fun b => (xs.map (fun a => f a b)).sum)).sum := by
  induction xs with
  | nil =>
      change (0 : Int) = (ys.map (fun _ => (0 : Int))).sum
      exact (map_zero_sum ys).symm
  | cons a rest ih =>
      simp only [List.map_cons, List.sum_cons]
      rw [ih]
      exact (sum_map_add ys (fun b => f a b)
        (fun b => (rest.map (fun z => f z b)).sum)).symm

theorem weighted_pair_symmetric (n : Mode) (f g : Polynomial) :
    weightedPair n f g = weightedPair n g f := by
  unfold weightedPair weightedOne
  calc
    (f.map (fun a => (g.map (fun b => weightedMode n a b)).sum)).sum =
      (f.map (fun a => (g.map (fun b => weightedMode n b a)).sum)).sum := by
        congr 1
        apply List.map_congr_left
        intro a ha
        congr 1
        apply List.map_congr_left
        intro b hb
        exact weighted_mode_swap n a b
    _ = (g.map (fun b => (f.map (fun a => weightedMode n b a)).sum)).sum :=
      double_sum_swap f g (fun a b => weightedMode n b a)

theorem weighted_pair_add_left (n : Mode) (a b c : Polynomial) :
    weightedPair n (a++b) c =
      weightedPair n a c + weightedPair n b c := by
  simp [weightedPair, List.map_append, List.sum_append]

theorem weighted_one_append (n a : Mode) (b c : Polynomial) :
    weightedOne n a (b++c) =
      weightedOne n a b + weightedOne n a c := by
  simp [weightedOne, List.map_append, List.sum_append]

theorem weighted_pair_add_right (n : Mode) (a b c : Polynomial) :
    weightedPair n a (b++c) =
      weightedPair n a b + weightedPair n a c := by
  induction a with
  | nil => simp [weightedPair]
  | cons x rest ih =>
      change weightedOne n x (b++c) + weightedPair n rest (b++c) =
        (weightedOne n x b + weightedPair n rest b) +
        (weightedOne n x c + weightedPair n rest c)
      rw [weighted_one_append, ih]
      omega

private theorem triple_frequency_sum (i : Axis)
    (n a b : Mode) (h : tripleMatch n a b) :
    freq i n + freq i a + freq i b = 0 := by
  rcases axis_cases i with hi | hi | hi <;>
    subst i
  · simpa [freq] using h.1
  · simpa [freq] using h.2.1
  · simpa [freq] using h.2.2

-- Every monomial contribution at zero Fourier frequency has vanishing
-- total Euler-derivative coefficient, even for nonconstant lapse n.
theorem triple_zero_mode_derivative (i : Axis)
    (n a b : Mode) :
    weightedMode (E i n) a b +
    weightedMode n (E i a) b +
    weightedMode n a (E i b) = 0 := by
  change
    (if tripleMatch n a b then ((freq i n*n.c)*a.c)*b.c else 0) +
    (if tripleMatch n a b then (n.c*(freq i a*a.c))*b.c else 0) +
    (if tripleMatch n a b then (n.c*a.c)*(freq i b*b.c) else 0) = 0
  by_cases h : tripleMatch n a b
  · simp only [if_pos h]
    have hz := triple_frequency_sum i n a b h
    calc
      ((freq i n*n.c)*a.c)*b.c +
          (n.c*(freq i a*a.c))*b.c +
          (n.c*a.c)*(freq i b*b.c) =
        (freq i n + freq i a + freq i b)*(n.c*a.c*b.c) := by
          rw [Int.add_mul, Int.add_mul]
          ac_rfl
      _ = 0 := by rw [hz]; simp
  · simp [h]

theorem weighted_one_derivative_balance (i : Axis)
    (n a : Mode) (bs : Polynomial) :
    weightedOne (E i n) a bs +
    weightedOne n (E i a) bs +
    weightedOne n a (derivative i bs) = 0 := by
  induction bs with
  | nil => simp [weightedOne, derivative]
  | cons b rest ih =>
      change
        (weightedMode (E i n) a b +
          weightedOne (E i n) a rest) +
        (weightedMode n (E i a) b +
          weightedOne n (E i a) rest) +
        (weightedMode n a (E i b) +
          weightedOne n a (derivative i rest)) = 0
      have hm := triple_zero_mode_derivative i n a b
      omega

-- The genuine periodic integration-by-parts identity for arbitrary
-- finite Fourier polynomials and a NONCONSTANT lapse character.
theorem weighted_derivative_balance (i : Axis)
    (n : Mode) (f g : Polynomial) :
    weightedPair (E i n) f g +
    weightedPair n (derivative i f) g +
    weightedPair n f (derivative i g) = 0 := by
  induction f with
  | nil => simp [weightedPair, derivative]
  | cons a rest ih =>
      change
        (weightedOne (E i n) a g +
          weightedPair (E i n) rest g) +
        (weightedOne n (E i a) g +
          weightedPair n (derivative i rest) g) +
        (weightedOne n a (derivative i g) +
          weightedPair n rest (derivative i g)) = 0
      have hm := weighted_one_derivative_balance i n a g
      omega

theorem derivative_append (i : Axis) (f h : Polynomial) :
    derivative i (f++h) = derivative i f ++ derivative i h := by
  simp [derivative, List.map_append]

-- Exact quadratic Taylor expansion without discarding any remainder.
theorem weighted_quadratic_expansion (n : Mode) (f h : Polynomial) :
    weightedPair n (f++h) (f++h) =
      weightedPair n f f + 2*weightedPair n f h +
      weightedPair n h h := by
  calc
    weightedPair n (f++h) (f++h) =
        weightedPair n f (f++h) +
        weightedPair n h (f++h) :=
          weighted_pair_add_left n f h (f++h)
    _ = (weightedPair n f f + weightedPair n f h) +
        (weightedPair n h f + weightedPair n h h) := by
          rw [weighted_pair_add_right, weighted_pair_add_right]
    _ = weightedPair n f f + 2*weightedPair n f h +
        weightedPair n h h := by
          rw [weighted_pair_symmetric n h f]
          omega

def sum3 (f : Axis → Int) : Int := f 0 + f 1 + f 2

def energy (n : Mode) (φ π : Polynomial) : Int :=
  weightedPair n π π +
  sum3 (fun i => weightedPair n (derivative i φ) (derivative i φ))

def firstVariation (n : Mode) (φ π h r : Polynomial) : Int :=
  2*(weightedPair n π r +
     sum3 (fun i => weightedPair n (derivative i φ) (derivative i h)))

def adjointVariation (n : Mode) (φ π h r : Polynomial) : Int :=
  2*(weightedPair n π r -
    sum3 (fun i =>
      weightedPair (E i n) (derivative i φ) h +
      weightedPair n (derivative i (derivative i φ)) h))

-- The quadratic field energy at φ+h,π+r has its true first-order
-- term plus a separate, exact second-order remainder E_n(h,r).
theorem exact_smeared_energy_expansion (n : Mode)
    (φ π h r : Polynomial) :
    energy n (φ++h) (π++r) =
      energy n φ π + firstVariation n φ π h r +
        energy n h r := by
  simp only [energy, firstVariation, sum3, derivative_append]
  rw [weighted_quadratic_expansion n π r,
      weighted_quadratic_expansion n (derivative 0 φ) (derivative 0 h),
      weighted_quadratic_expansion n (derivative 1 φ) (derivative 1 h),
      weighted_quadratic_expansion n (derivative 2 φ) (derivative 2 h)]
  omega

theorem weighted_energy_ibp (i : Axis)
    (n : Mode) (φ h : Polynomial) :
    weightedPair n (derivative i φ) (derivative i h) =
      -(weightedPair (E i n) (derivative i φ) h +
        weightedPair n (derivative i (derivative i φ)) h) := by
  have hh := weighted_derivative_balance i n (derivative i φ) h
  omega

-- Derivatives are moved to the field/lapse, yielding the exact
-- cotangent variation in test-function pairing form.
theorem first_variation_equals_adjoint (n : Mode)
    (φ π h r : Polynomial) :
    firstVariation n φ π h r =
      adjointVariation n φ π h r := by
  have h0 := weighted_energy_ibp 0 n φ h
  have h1 := weighted_energy_ibp 1 n φ h
  have h2 := weighted_energy_ibp 2 n φ h
  simp only [firstVariation, adjointVariation, sum3]
  omega

theorem nontrivial_smeared_read :
    weightedPair zeroCharacter [plusOneX] [⟨-1,0,0,1⟩] = 1 := by
  decide

theorem mismatched_smeared_read :
    weightedPair zeroCharacter [plusOneX] [zeroCharacter] = 0 := by
  decide

#print axioms weighted_pair_symmetric
#print axioms triple_zero_mode_derivative
#print axioms weighted_derivative_balance
#print axioms weighted_quadratic_expansion
#print axioms exact_smeared_energy_expansion
#print axioms first_variation_equals_adjoint
#print axioms nontrivial_smeared_read

end FourierHamiltonian010n
