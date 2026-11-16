import Init.Data.Rat.Basic
import proofs.FourierPairing010g

/-!
# Minimum Mechanics 010n — canonical Fourier-field Poisson pairing

Fixed references 010a–010m are immutable inputs.
This module realizes the canonical symplectic pairing for arbitrary
finite Fourier-polynomial test fields in three spatial directions.
The Fourier zero-mode is the actual read, pairing opposite wave addresses:
  <f,g> = (fg)_0 = Σ_(k+l=0) f_k g_l.

A linear observable is L_(f,g)[φ,π] = <f,φ> + <g,π> + c.
Its gradients are derived directly by additivity of the pairing:
  ∂L/∂φ=f, ∂L/∂π=g (relative to this pairing).
The defined canonical Poisson tensor of two linear observables is
  {L_(f,g),L_(h,j)} = <f,j> - <g,h>.
All three physical field components contribute separately.

Proves:
* pairing symmetry and finite additivity, not only monomial pairing;
* antisymmetry and Jacobi for affine Fourier-field observables;
* all three Fourier coordinate/momentum diagonal canonical brackets;
* Gauss gradients commute and magnetic curl pairs annihilate gradients;
* mixed derivative skew-adjointness in the zero-mode reader.

This is a finite-support Fourier group algebra over Int using Euler
derivatives k_i, not a smooth infinite-dimensional symplectic
manifold or Dirac–ADM functional Hamiltonian. The physical angular
derivative carries i after complexification. No new axioms / sorry.
-/

set_option autoImplicit false

namespace FourierCanonical010n

open FourierTorus010e FourierPairing010g

abbrev Polynomial := FourierTorus010e.Polynomial
abbrev Axis := Fin 3

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

theorem finite_pairing_symmetric (f g : Polynomial) :
    FourierPairing010g.pairing f g =
      FourierPairing010g.pairing g f := by
  unfold FourierPairing010g.pairing FourierPairing010g.pairOne
  calc
    (f.map (fun a => (g.map (fun b => pair a b)).sum)).sum =
      (f.map (fun a => (g.map (fun b => pair b a)).sum)).sum := by
        congr 1
        apply List.map_congr_left
        intro a ha
        congr 1
        apply List.map_congr_left
        intro b hb
        exact pair_symmetric a b
    _ = (g.map (fun b => (f.map (fun a => pair b a)).sum)).sum :=
      double_sum_swap f g (fun a b => pair b a)

structure FieldTest where
  dq : Axis → Polynomial
  dp : Axis → Polynomial
  c : Int

def zeroTest : FieldTest :=
  ⟨fun _ => [], fun _ => [], 0⟩

def constantTest (c : Int) : FieldTest :=
  ⟨fun _ => [], fun _ => [], c⟩

def coordinateTest (i : Axis) (f : Polynomial) : FieldTest :=
  ⟨fun j => if i=j then f else [], fun _ => [],0⟩

def momentumTest (i : Axis) (f : Polynomial) : FieldTest :=
  ⟨fun _ => [], fun j => if i=j then f else [],0⟩

def sum3 (f : Axis → Int) : Int := f 0+f 1+f 2

-- This pairing is a defined three-component canonical Poisson bracket.
def pb (f g : FieldTest) : Int :=
  sum3 (fun i =>
    FourierPairing010g.pairing (f.dq i) (g.dp i) -
    FourierPairing010g.pairing (f.dp i) (g.dq i))

def poisson (f g : FieldTest) : FieldTest := constantTest (pb f g)

theorem pairing_empty_left (f : Polynomial) :
    FourierPairing010g.pairing [] f = 0 := rfl

theorem pairing_empty_right (f : Polynomial) :
    FourierPairing010g.pairing f [] = 0 := by
  change (f.map (fun _ => (0 : Int))).sum = 0
  exact map_zero_sum f

theorem pb_antisymmetric (f g : FieldTest) :
    pb f g = -(pb g f) := by
  have h0 := finite_pairing_symmetric (f.dq 0) (g.dp 0)
  have h1 := finite_pairing_symmetric (f.dq 1) (g.dp 1)
  have h2 := finite_pairing_symmetric (f.dq 2) (g.dp 2)
  have h3 := finite_pairing_symmetric (f.dp 0) (g.dq 0)
  have h4 := finite_pairing_symmetric (f.dp 1) (g.dq 1)
  have h5 := finite_pairing_symmetric (f.dp 2) (g.dq 2)
  simp only [pb, sum3]
  omega

theorem pb_const_left (c : Int) (f : FieldTest) :
    pb (constantTest c) f = 0 := by
  simp [pb, sum3, constantTest, pairing_empty_left]

theorem pb_const_right (c : Int) (f : FieldTest) :
    pb f (constantTest c) = 0 := by
  simp [pb, sum3, constantTest, pairing_empty_right]

theorem canonical_fourier_jacobi (f g h : FieldTest) :
    pb (poisson f g) h +
    pb (poisson g h) f +
    pb (poisson h f) g = 0 := by
  simp [poisson, pb_const_left]

private theorem axis_cases (i : Axis) :
    i=0 ∨ i=1 ∨ i=2 := by decide

theorem coordinate_momentum_bracket (i : Axis)
    (f g : Polynomial) :
    pb (coordinateTest i f) (momentumTest i g) =
      FourierPairing010g.pairing f g := by
  rcases axis_cases i with hi | hi | hi <;> subst i <;>
    simp [pb, sum3, coordinateTest, momentumTest,
      pairing_empty_left, pairing_empty_right]

theorem different_coordinate_momentum_bracket
    (i j : Axis) (f g : Polynomial) (hne : i ≠ j) :
    pb (coordinateTest i f) (momentumTest j g) = 0 := by
  rcases axis_cases i with hi | hi | hi <;> subst i <;>
    rcases axis_cases j with hj | hj | hj <;> subst j <;>
    simp_all [pb, sum3, coordinateTest, momentumTest,
      pairing_empty_left, pairing_empty_right]

def characterX : Polynomial := [plusOneX]
def inverseCharacterX : Polynomial := [⟨-1,0,0,1⟩]

theorem inverse_frequency_kronecker :
    pb (coordinateTest 0 characterX)
       (momentumTest 0 inverseCharacterX) = 1 := by decide

theorem mismatched_frequency_zero :
    pb (coordinateTest 0 characterX)
       (momentumTest 0 [zeroCharacter]) = 0 := by decide

private theorem mode_derivatives_commute
    (i j : Axis) (a : Mode) :
    E i (E j a) = E j (E i a) := by
  rcases axis_cases i with hi | hi | hi <;>
    rcases axis_cases j with hj | hj | hj <;>
    subst i <;> subst j <;>
    simp [E, freq, Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]

theorem finite_fourier_derivatives_commute
    (i j : Axis) (f : Polynomial) :
    derivative i (derivative j f) =
      derivative j (derivative i f) := by
  simp only [derivative, List.map_map]
  apply List.map_congr_left
  intro a ha
  exact mode_derivatives_commute i j a

theorem cross_derivative_pairing
    (i j : Axis) (f g : Polynomial) :
    FourierPairing010g.pairing (derivative i f) (derivative j g) =
      FourierPairing010g.pairing (derivative j f) (derivative i g) := by
  have hi := pairing_integration_by_parts j (derivative i f) g
  have hj := pairing_integration_by_parts i (derivative j f) g
  rw [finite_fourier_derivatives_commute j i f] at hi
  omega

-- The magnetic two-form F_01 has canonical q-test gradients
-- (+D1 f, -D0 f); Gauss has canonical p-test gradients D_i α.
-- Their PB vanishes because the Fourier Hessian is symmetric.
def curlGaugeBracket01 (f α : Polynomial) : Int :=
  pb (coordinateTest 0 (derivative 1 f))
     (momentumTest 0 (derivative 0 α)) -
  pb (coordinateTest 1 (derivative 0 f))
     (momentumTest 1 (derivative 1 α))

theorem curl_annihilates_gauss_01 (f α : Polynomial) :
    curlGaugeBracket01 f α = 0 := by
  rw [curlGaugeBracket01,
      coordinate_momentum_bracket,
      coordinate_momentum_bracket]
  have h := cross_derivative_pairing 1 0 f α
  omega

def gaussComponent (i : Axis) (α : Polynomial) : FieldTest :=
  momentumTest i (derivative i α)

theorem gauss_gauss_canonical (i j : Axis)
    (α β : Polynomial) :
    pb (gaussComponent i α) (gaussComponent j β) = 0 := by
  rcases axis_cases i with hi | hi | hi <;> subst i <;>
    rcases axis_cases j with hj | hj | hj <;> subst j <;>
    simp [pb, sum3, gaussComponent, momentumTest,
      pairing_empty_left, pairing_empty_right]

#print axioms finite_pairing_symmetric
#print axioms pb_antisymmetric
#print axioms canonical_fourier_jacobi
#print axioms coordinate_momentum_bracket
#print axioms different_coordinate_momentum_bracket
#print axioms inverse_frequency_kronecker
#print axioms mismatched_frequency_zero
#print axioms finite_fourier_derivatives_commute
#print axioms cross_derivative_pairing
#print axioms curl_annihilates_gauss_01
#print axioms gauss_gauss_canonical

end FourierCanonical010n
