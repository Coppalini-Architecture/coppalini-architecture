import Init.Data.Rat.Basic
import proofs.PalatiniBoundary010i
import proofs.ConnectionPalatini010h

/-!
# Minimum Mechanics 010j — Contracted Palatini divergence on curved coframes

Fixed parents: 010a–010i; their hashes and scopes remain unchanged.

This local three-dimensional proof closes the algebraic seam between
the torsion-free Palatini curvature variation from 010h and the Palatini
vector current from 010i. In a coordinate frame define

  J^k = B^{lj} V^k_{jl} - B^{lk} V^j_{jl},
  dB_k^{lj} = -Γ^l_{km}B^{mj} - Γ^j_{km}B^{lm}.

B is an arbitrary inverse-metric matrix, Γ is a torsion-free connection,
V is an arbitrary tensor δΓ, and dV is its ordinary derivative jet.
Then the exact contracted identity is

  B^{lj}( ∇_k V^k_{jl} - ∇_j V^k_{kl} )
     = ∂_k J^k + Γ^k_{km} J^m.

The proof expands every 3D contraction and uses only exact integer
distributivity. The metric-compatibility derivative dB is CONSTRUCTED,
not postulated as a curvature theorem.

Boundary: this is a finite indexed tensor-jet identity. The smooth
Levi-Civita bundle and Stokes theorem on a compact or falloff-controlled
spatial manifold are not supplied. The full ADM functional algebra remains
OPEN. No new axioms, sorry, or Mathlib dependency.
-/
set_option autoImplicit false

namespace ContractedPalatini010j

abbrev Axis := Fin 3
abbrev Mat3 := MetricInverse010i.Mat3
abbrev Conn := ConnectionPalatini010h.Connection
abbrev ConnJet := ConnectionPalatini010h.ConnectionJet
abbrev InvJet := Axis → Axis → Axis → Int

def sum3 (f : Axis → Int) : Int := f 0 + f 1 + f 2

-- Ordinary derivatives of B prescribed by metric compatibility ∇B=0.
def compatibleInverseJet (B : Mat3) (G : Conn) : InvJet :=
  fun a l j =>
    -sum3 (fun m =>
      G l a m * B m j + G j a m * B l m)

def covDInverse (B : Mat3) (G : Conn) (dB : InvJet)
    (a l j : Axis) : Int :=
  dB a l j +
  sum3 (fun m =>
    G l a m * B m j + G j a m * B l m)

theorem inverse_compatibility_exact
    (B : Mat3) (G : Conn) (a l j : Axis) :
    covDInverse B G (compatibleInverseJet B G) a l j = 0 := by
  simp only [covDInverse, compatibleInverseJet]
  omega

def palatiniCurrent (B : Mat3) (V : Conn) (k : Axis) : Int :=
  sum3 (fun l => sum3 (fun j => B l j * V k j l)) -
  sum3 (fun l => sum3 (fun j => B l k * V j j l))

theorem current_matches_010i (B : Mat3) (V : Conn) (k : Axis) :
    palatiniCurrent B V k =
      PalatiniBoundary010i.palatiniCurrent B V k := by
  rfl

def contractedRicciVariation
    (B : Mat3) (G V : Conn) (dV : ConnJet) : Int :=
  sum3 (fun l => sum3 (fun j => B l j *
    sum3 (fun k =>
      ConnectionPalatini010h.covDVar G V dV k k j l -
      ConnectionPalatini010h.covDVar G V dV j k k l)))

-- The derivative ∂_k J^k, explicitly derived by the Leibniz rule from
-- both B and V. The derivative jet dB has all three spatial directions.
def ordinaryDivergenceCurrent
    (B : Mat3) (V : Conn) (dB : InvJet) (dV : ConnJet) : Int :=
  sum3 (fun k => sum3 (fun l => sum3 (fun j =>
    dB k l j * V k j l + B l j * dV k k j l -
    dB k l k * V j j l - B l k * dV k j j l)))

-- ∇_k J^k for a contravariant vector.
def covariantDivergenceCurrent
    (B : Mat3) (G V : Conn) (dB : InvJet) (dV : ConnJet) : Int :=
  ordinaryDivergenceCurrent B V dB dV +
  sum3 (fun k => sum3 (fun m =>
    G k k m * palatiniCurrent B V m))

-- The load-bearing identity: fully expanded contraction of Palatini
-- covariant derivatives equals covariant divergence of the current.
-- Its only physical premises are torsion-freedom and the metric-
-- compatibility derivative chosen above.
theorem contracted_Palatini_is_divergence
    (B : Mat3) (G V : Conn) (dV : ConnJet)
    (ht : ∀ m a b, G m a b = G m b a) :
    contractedRicciVariation B G V dV =
      covariantDivergenceCurrent B G V (compatibleInverseJet B G) dV := by
  have h000 := ht (0:Axis) 0 1
  have h001 := ht (0:Axis) 0 2
  have h002 := ht (0:Axis) 1 2
  have h100 := ht (1:Axis) 0 1
  have h101 := ht (1:Axis) 0 2
  have h102 := ht (1:Axis) 1 2
  have h200 := ht (2:Axis) 0 1
  have h201 := ht (2:Axis) 0 2
  have h202 := ht (2:Axis) 1 2
  simp only [contractedRicciVariation, covariantDivergenceCurrent,
    ordinaryDivergenceCurrent, compatibleInverseJet, palatiniCurrent,
    ConnectionPalatini010h.covDVar, ConnectionPalatini010h.sum3,
    sum3] at *
  simp only [Int.mul_add, Int.mul_sub, Int.add_mul, Int.sub_mul,
    Int.neg_mul, Int.mul_neg, Int.mul_assoc] at *
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc] at *
  simp only [← Int.mul_assoc] at *
  omega

-- Transport of the actual curvature tensor: the 010h Palatini identity
-- supplies δR^k_{l k j}, and contraction is then exactly the divergence.
def geometricRicciDifferential
    (B : Mat3) (G V : Conn) (dV : ConnJet) : Int :=
  sum3 (fun l => sum3 (fun j => B l j *
    sum3 (fun k =>
      ConnectionPalatini010h.deltaR G V dV k l k j)))

theorem curved_Ricci_first_variation_to_boundary
    (B : Mat3) (G V : Conn) (dV : ConnJet)
    (ht : ∀ m a b, G m a b = G m b a) :
    geometricRicciDifferential B G V dV =
      covariantDivergenceCurrent B G V (compatibleInverseJet B G) dV := by
  have hPal : geometricRicciDifferential B G V dV =
      contractedRicciVariation B G V dV := by
    simp only [geometricRicciDifferential, contractedRicciVariation]
    congr 1
    funext l
    congr 1
    funext j
    congr 1
    funext k
    exact ConnectionPalatini010h.palatini_covariant_curvature
      G V dV k l k j ht
  rw [hPal]
  exact contracted_Palatini_is_divergence B G V dV ht

#print axioms inverse_compatibility_exact
#print axioms current_matches_010i
#print axioms contracted_Palatini_is_divergence
#print axioms curved_Ricci_first_variation_to_boundary

end ContractedPalatini010j
