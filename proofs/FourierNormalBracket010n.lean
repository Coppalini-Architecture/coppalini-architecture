import Init.Data.Rat.Basic
import proofs.FourierHamiltonian010n

/-!
# Minimum Mechanics 010n — exact canonical Fourier scalar normal bracket

This is an actual finite-Fourier quadratic-field Poisson calculation,
not a stipulated ADM constraint algebra.

The previous certificate derived the first variation of
  E_n(φ,π)=W_n(π,π)+Σ_i W_n(D_iφ,D_iφ).
Its Fourier-mode cotangent gradients are:
  (δE_n/δπ)_(n+b) = 2n_c b_c
  (δE_n/δφ)_(n+a) =
      -2n_c a_c Σ_i(n_i+a_i)a_i.

The canonical zero-mode symplectic pairing gives:
  {E_n,E_m} = 4 Σ_(n+m+a+b=0)
     n_c m_c a_c b_c ((m-n)·a).

The right-hand side is the exact Fourier address form of
  D[4(n ∂m - m ∂n)] = 4I[(n D_i m-m D_i n) π D_iφ],
with all three directions and with no mode cutoff. This explicitly
derives the normal–normal bracket of the finite scalar theory.

JURISDICTION: finite-support integer Fourier group algebra with Euler
D_i (physical angular ∂_i=iD_i after complexification). In particular
the physical metric and its canonical momentum are not part of this
Hamiltonian. D–H closure, C∞ completion, and the full curved ADM
hypersurface-deformation algebra remain OPEN.

Lean 4.33.0: no new axioms or sorry.
-/
set_option autoImplicit false

namespace FourierNormalBracket010n

open FourierTorus010e FourierPairing010g FourierCanonical010n
open FourierHamiltonian010n

abbrev Polynomial := FourierTorus010e.Polynomial

def gradientWave (n a : Mode) : Mode :=
  ⟨n.kx+a.kx,n.ky+a.ky,n.kz+a.kz,n.c*a.c⟩

def momentumGradientMode (n b : Mode) : Mode :=
  ⟨n.kx+b.kx,n.ky+b.ky,n.kz+b.kz,2*(n.c*b.c)⟩

def lapFrequency (n a : Mode) : Int :=
  (n.kx+a.kx)*a.kx +
  (n.ky+a.ky)*a.ky +
  (n.kz+a.kz)*a.kz

def scalarGradientMode (n a : Mode) : Mode :=
  ⟨n.kx+a.kx,n.ky+a.ky,n.kz+a.kz,
   -(2*(n.c*a.c)*lapFrequency n a)⟩

def momentumGradient (n : Mode) (π : Polynomial) : Polynomial :=
  π.map (momentumGradientMode n)

def scalarGradient (n : Mode) (φ : Polynomial) : Polynomial :=
  φ.map (scalarGradientMode n)

abbrev quadrupleMatch (n m a b : Mode) : Prop :=
  n.kx+m.kx+a.kx+b.kx=0 ∧
  n.ky+m.ky+a.ky+b.ky=0 ∧
  n.kz+m.kz+a.kz+b.kz=0

def fluxAddress (n m a b : Mode) : Int :=
  if quadrupleMatch n m a b then
    4*((n.c*m.c)*(a.c*b.c))*
      ((m.kx-n.kx)*a.kx +
       (m.ky-n.ky)*a.ky +
       (m.kz-n.kz)*a.kz)
  else 0

theorem left_match (n m a b : Mode) :
    opposite (scalarGradientMode n a) (momentumGradientMode m b) ↔
      quadrupleMatch n m a b := by
  change
    ((n.kx+a.kx)+(m.kx+b.kx)=0 ∧
     (n.ky+a.ky)+(m.ky+b.ky)=0 ∧
     (n.kz+a.kz)+(m.kz+b.kz)=0) ↔
    (n.kx+m.kx+a.kx+b.kx=0 ∧
     n.ky+m.ky+a.ky+b.ky=0 ∧
     n.kz+m.kz+a.kz+b.kz=0)
  constructor
  · intro h
    exact ⟨by omega,by omega,by omega⟩
  · intro h
    exact ⟨by omega,by omega,by omega⟩

theorem right_match (n m a b : Mode) :
    opposite (momentumGradientMode n b) (scalarGradientMode m a) ↔
      quadrupleMatch n m a b := by
  change
    ((n.kx+b.kx)+(m.kx+a.kx)=0 ∧
     (n.ky+b.ky)+(m.ky+a.ky)=0 ∧
     (n.kz+b.kz)+(m.kz+a.kz)=0) ↔
    (n.kx+m.kx+a.kx+b.kx=0 ∧
     n.ky+m.ky+a.ky+b.ky=0 ∧
     n.kz+m.kz+a.kz+b.kz=0)
  constructor
  · intro h
    exact ⟨by omega,by omega,by omega⟩
  · intro h
    exact ⟨by omega,by omega,by omega⟩

-- All gradient factors are actual coefficients of the first-order
-- derivative of E_n, not arbitrary vector-field brackets.
theorem monomial_normal_normal (n m a b : Mode) :
    pair (scalarGradientMode n a) (momentumGradientMode m b) -
    pair (momentumGradientMode n b) (scalarGradientMode m a) =
      fluxAddress n m a b := by
  by_cases h : quadrupleMatch n m a b
  · have hl : opposite (scalarGradientMode n a)
      (momentumGradientMode m b) := (left_match n m a b).mpr h
    have hr : opposite (momentumGradientMode n b)
      (scalarGradientMode m a) := (right_match n m a b).mpr h
    simp only [pair, if_pos hl, if_pos hr, fluxAddress, if_pos h]
    simp only [scalarGradientMode, momentumGradientMode,
      lapFrequency, Int.mul_add, Int.mul_sub, Int.add_mul,
      Int.sub_mul, Int.neg_mul, Int.mul_neg, Int.mul_assoc]
    simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
    simp only [← Int.mul_assoc]
    omega
  · have hl : ¬opposite (scalarGradientMode n a)
      (momentumGradientMode m b) := by
        intro hh
        exact h ((left_match n m a b).mp hh)
    have hr : ¬opposite (momentumGradientMode n b)
      (scalarGradientMode m a) := by
        intro hh
        exact h ((right_match n m a b).mp hh)
    simp [pair, fluxAddress, h, hl, hr]

private theorem sum_map_difference {α : Type}
    (xs : List α) (f g : α → Int) :
    (xs.map f).sum - (xs.map g).sum =
      (xs.map (fun x => f x-g x)).sum := by
  induction xs with
  | nil => simp
  | cons a rest ih =>
      simp only [List.map_cons, List.sum_cons]
      omega

private def doubleSum {α β : Type}
    (xs : List α) (ys : List β) (f : α → β → Int) : Int :=
  (xs.map (fun a => (ys.map (fun b => f a b)).sum)).sum

private theorem double_sum_swap {α β : Type}
    (xs : List α) (ys : List β) (f : α → β → Int) :
    doubleSum xs ys f = doubleSum ys xs (fun b a => f a b) := by
  unfold doubleSum
  induction xs with
  | nil =>
      change (0 : Int) = (ys.map (fun _ => (0 : Int))).sum
      induction ys with
      | nil => rfl
      | cons b bs ih =>
          change (0 : Int) = (0 : Int) +
            (bs.map (fun _ => (0 : Int))).sum
          rw [← ih]
          omega
  | cons a rest ih =>
      simp only [List.map_cons, List.sum_cons]
      rw [ih]
      have hadd (zs : List β) (f g : β → Int) :
          (zs.map (fun z => f z+g z)).sum =
            (zs.map f).sum+(zs.map g).sum := by
        induction zs with
        | nil => simp
        | cons z zs ihz =>
            simp only [List.map_cons, List.sum_cons]
            omega
      have h := hadd ys (fun b => f a b)
        (fun b => (rest.map (fun z => f z b)).sum)
      exact h.symm

private theorem double_sum_difference {α β : Type}
    (xs : List α) (ys : List β) (f g : α → β → Int) :
    doubleSum xs ys f - doubleSum xs ys g =
      doubleSum xs ys (fun a b => f a b-g a b) := by
  unfold doubleSum
  calc
    (xs.map (fun a => (ys.map (fun b => f a b)).sum)).sum -
      (xs.map (fun a => (ys.map (fun b => g a b)).sum)).sum =
      (xs.map (fun a => (ys.map (fun b => f a b)).sum -
        (ys.map (fun b => g a b)).sum)).sum :=
        sum_map_difference xs _ _
    _ = (xs.map (fun a =>
      (ys.map (fun b => f a b-g a b)).sum)).sum := by
        apply congrArg List.sum
        apply List.map_congr_left
        intro a ha
        exact sum_map_difference ys _ _

private theorem double_sum_congr {α β : Type}
    (xs : List α) (ys : List β) (f g : α → β → Int)
    (h : ∀ a b, f a b = g a b) :
    doubleSum xs ys f = doubleSum xs ys g := by
  unfold doubleSum
  apply congrArg List.sum
  apply List.map_congr_left
  intro a ha
  apply congrArg List.sum
  apply List.map_congr_left
  intro b hb
  exact h a b

-- The canonical quadratic Poisson bracket is DEFINED from the Fourier
-- field test pairing, with both gradient fields explicitly constructed.
def normalPoisson (n m : Mode) (φ π : Polynomial) : Int :=
  pairing (scalarGradient n φ) (momentumGradient m π) -
  pairing (momentumGradient n π) (scalarGradient m φ)

def momentumFlux (n m : Mode) (φ π : Polynomial) : Int :=
  doubleSum φ π (fluxAddress n m)

theorem canonical_normal_normal_fourier
    (n m : Mode) (φ π : Polynomial) :
    normalPoisson n m φ π = momentumFlux n m φ π := by
  have hswap := double_sum_swap π φ
    (fun b a =>
      pair (momentumGradientMode n b) (scalarGradientMode m a))
  calc
    normalPoisson n m φ π =
      doubleSum φ π (fun a b =>
        pair (scalarGradientMode n a) (momentumGradientMode m b)) -
      doubleSum π φ (fun b a =>
        pair (momentumGradientMode n b) (scalarGradientMode m a)) := by
          simp only [normalPoisson, scalarGradient, momentumGradient,
            pairing, pairOne, doubleSum, List.map_map,
            Function.comp_def]
    _ = doubleSum φ π (fun a b =>
        pair (scalarGradientMode n a) (momentumGradientMode m b)) -
      doubleSum φ π (fun a b =>
        pair (momentumGradientMode n b) (scalarGradientMode m a)) := by
          rw [hswap]
    _ = doubleSum φ π (fun a b =>
        pair (scalarGradientMode n a) (momentumGradientMode m b) -
        pair (momentumGradientMode n b) (scalarGradientMode m a)) :=
          double_sum_difference φ π _ _
    _ = momentumFlux n m φ π := by
      unfold momentumFlux
      apply double_sum_congr
      intro a b
      exact monomial_normal_normal n m a b

-- A nontrivial mode quartet with n+m+φ+π=0 produces momentum flux.
def nWave : Mode := ⟨1,0,0,1⟩
def mWave : Mode := ⟨0,1,0,1⟩
def phiWave : Mode := ⟨1,0,0,1⟩
def piWave : Mode := ⟨-2,-1,0,1⟩

theorem nonzero_canonical_normal_bracket :
    normalPoisson nWave mWave [phiWave] [piWave] = -4 := by decide

theorem unmatched_wave_bracket_zero :
    normalPoisson nWave mWave [phiWave] [zeroCharacter] = 0 := by decide

#print axioms monomial_normal_normal
#print axioms canonical_normal_normal_fourier
#print axioms nonzero_canonical_normal_bracket
#print axioms unmatched_wave_bracket_zero

end FourierNormalBracket010n
