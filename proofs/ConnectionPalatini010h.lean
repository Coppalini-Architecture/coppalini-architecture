import Init.Data.Rat.Basic
import proofs.LaurentPoisson010g

/-!
# Minimum Mechanics 010h — full local Palatini curvature variation

FIXED INPUT: 010a–010g certificates, left unchanged.
PROVED HERE: exact polynomial first variation of the curvature tensor
of an arbitrary 3-dimensional affine connection, including its quadratic
remainder; and the covariant Palatini identity under torsion-freedom.

This is a *pointwise coordinate jet* statement. The connection and its
first derivatives are independent algebraic inputs. To apply it to a smooth
spatial manifold, a compatible connection, covariant derivative, tensor
density/integration, and metric variation must be supplied separately.
No curvature field equations or empirical claims are implied.

Conventions:
 R^k_{l i j} =
    ∂_i Γ^k_{j l} - ∂_j Γ^k_{i l}
    + Γ^k_{i m} Γ^m_{j l} - Γ^k_{j m} Γ^m_{i l}.
A first variation V=δΓ has linear coefficient δR and a quadratic
remainder R_quad(V), verified exactly for Γ+tV.

Core Lean 4.33.0 with no Mathlib, sorry, or additional axioms.
-/

set_option autoImplicit false

namespace ConnectionPalatini010h

abbrev Axis := Fin 3
abbrev Connection := Axis → Axis → Axis → Int
abbrev ConnectionJet := Axis → Axis → Axis → Axis → Int

def sum3 (f : Axis → Int) : Int := f 0 + f 1 + f 2

def shiftConn (G V : Connection) (t : Int) : Connection :=
  fun k i j => G k i j + t * V k i j

def shiftJet (dG dV : ConnectionJet) (t : Int) : ConnectionJet :=
  fun a k i j => dG a k i j + t * dV a k i j

def quadraticCurv (G : Connection) (k l i j : Axis) : Int :=
  sum3 (fun m => G k i m * G m j l - G k j m * G m i l)

def R (G : Connection) (dG : ConnectionJet)
    (k l i j : Axis) : Int :=
  dG i k j l - dG j k i l + quadraticCurv G k l i j

def deltaR (G V : Connection) (dV : ConnectionJet)
    (k l i j : Axis) : Int :=
  dV i k j l - dV j k i l +
  sum3 (fun m =>
    V k i m * G m j l + G k i m * V m j l -
    V k j m * G m i l - G k j m * V m i l)

def secondR (V : Connection) (k l i j : Axis) : Int :=
  quadraticCurv V k l i j

-- Distributivity, in its precise finite-dimensional scalar office.
theorem product_first_second (a b da db t : Int) :
    (a+t*da)*(b+t*db) =
       a*b + t*(da*b+a*db) + (t*t)*(da*db) :=
  Maxwell010b.product_variation a b da db t

theorem curvature_polynomial_variation
    (G V : Connection) (dG dV : ConnectionJet)
    (t : Int) (k l i j : Axis) :
    R (shiftConn G V t) (shiftJet dG dV t) k l i j =
      R G dG k l i j +
      t * deltaR G V dV k l i j +
      (t*t) * secondR V k l i j := by
  simp only [R, shiftConn, shiftJet, deltaR, secondR, quadraticCurv, sum3]
  simp only [Int.mul_add, Int.add_mul, Int.mul_sub, Int.sub_mul,
    Int.mul_assoc, Int.neg_mul, Int.mul_neg]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
  simp only [← Int.mul_assoc]
  omega

-- A Christoffel variation is tensorial, hence the connection acts on its
-- upper index and on both covariant lower indices.
def covDVar (G V : Connection) (dV : ConnectionJet)
    (i k j l : Axis) : Int :=
  dV i k j l +
  sum3 (fun m =>
    G k i m * V m j l -
    G m i j * V k m l -
    G m i l * V k j m)

-- The exact Palatini tensorial statement requires Γ^m_ij = Γ^m_ji.
theorem palatini_covariant_curvature
    (G V : Connection) (dV : ConnectionJet)
    (k l i j : Axis)
    (torsionFree : ∀ m a b, G m a b = G m b a) :
    deltaR G V dV k l i j =
      covDVar G V dV i k j l -
      covDVar G V dV j k i l := by
  have h0 := torsionFree (0 : Axis) i j
  have h1 := torsionFree (1 : Axis) i j
  have h2 := torsionFree (2 : Axis) i j
  simp only [deltaR, covDVar, sum3]
  rw [h0, h1, h2]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc]
  omega

theorem curvature_antisymmetric
    (G : Connection) (dG : ConnectionJet) (k l i j : Axis) :
    R G dG k l i j = -R G dG k l j i := by
  simp only [R, quadraticCurv, sum3]
  simp only [Int.neg_add, Int.neg_sub, Int.sub_eq_add_neg]
  omega

-- Negative control: the second-order remainder carries genuine content.
def nonlinearConn : Connection :=
  fun k i j => if k = 0 ∧ i = 1 ∧ j = 0 then 1
    else if k = 1 ∧ i = 0 ∧ j = 1 then 1 else 0

theorem quadratic_remainder_nonzero :
    secondR nonlinearConn 0 1 1 0 ≠ 0 := by decide

-- At the flat Γ=0 address all nonlinear connection products vanish.
def flatConnection : Connection := fun _ _ _ => 0

theorem flat_first_variation
    (V : Connection) (dV : ConnectionJet) (k l i j : Axis) :
    deltaR flatConnection V dV k l i j =
      dV i k j l - dV j k i l := by
  simp [deltaR, flatConnection, sum3]

#print axioms product_first_second
#print axioms curvature_polynomial_variation
#print axioms palatini_covariant_curvature
#print axioms curvature_antisymmetric
#print axioms quadratic_remainder_nonzero
#print axioms flat_first_variation

end ConnectionPalatini010h
