import Init.Data.Rat.Basic
import proofs.ContractedPalatini010j
import proofs.CurvedEH010i

/-!
# Minimum Mechanics 010j — Curved Einstein–Hilbert Palatini composition

Predecessors 010a–010i retain all source hashes and claim strengths.
This file composes:
* the 010i *pointwise* curved EH density first variation;
* the 010h torsion-free Palatini curvature differential;
* the 010j contracted divergence identity with constructed dB.

For a supplied invertible g, B=g^{-1}, metric perturbation h, Ricci
tensor Ric, volume root v with first-order square response, connection
G, and variation V=δG, the complete pointwise EH variation carries
its curvature divergence explicitly. It is multiplied by v to avoid
division by 2 in the exact integer coefficient ring.

The Ricci tensor differential is stored transposed relative to the
usual coordinates so that trace(B*dRic) exactly matches B^{ij}dRic_ij
without imposing an unused B-symmetry premise; for a genuine
Levi-Civita connection Ric is symmetric. This storage convention is
only an addressing choice and is declared in the certificate.

BOUNDARY: The integrated √(g)∇J term still requires a smooth
volume-compatible covariant Stokes realization. Lapse-smearing,
the metric-compatible connection/metric jet relationship, and
functional canonical brackets remain OPEN.
No Mathlib, sorry, or added axioms.
-/
set_option autoImplicit false

namespace CurvedEHVariation010j

open MetricInverse010i MetricDeterminant010i CurvedEH010i
open ContractedPalatini010j

abbrev Axis := Fin 3
abbrev Conn := ConnectionPalatini010h.Connection
abbrev ConnJet := ConnectionPalatini010h.ConnectionJet
abbrev Mat3 := MetricInverse010i.Mat3

-- The row/column transpose is deliberate: traceProduct B R is B^ij R_ji.
def ricciDifferentialAddressed (G V : Conn) (dV : ConnJet) : Mat3 :=
  fun row col => sum3 (fun k =>
    ConnectionPalatini010h.deltaR G V dV k col k row)

theorem trace_curvature_address_identity
    (B : Mat3) (G V : Conn) (dV : ConnJet) :
    traceProduct B (ricciDifferentialAddressed G V dV) =
      geometricRicciDifferential B G V dV := by
  rfl

theorem contracted_Ricci_trace_is_divergence
    (B : Mat3) (G V : Conn) (dV : ConnJet)
    (ht : ∀ m a b, G m a b = G m b a) :
    traceProduct B (ricciDifferentialAddressed G V dV) =
      covariantDivergenceCurrent B G V (compatibleInverseJet B G) dV := by
  rw [trace_curvature_address_identity]
  exact curved_Ricci_first_variation_to_boundary B G V dV ht

def EHvariationWithPalatini (v dv : Int) (B h Ric : Mat3)
    (G V : Conn) (dV : ConnJet) (Lambda : Int) : Int :=
  deltaEHdensity v dv B h Ric
    (ricciDifferentialAddressed G V dV) Lambda

-- The nonflat curvature/boundary suture, with every normalization kept.
theorem curved_EH_variation_with_Palatini_flux
    (g B h Ric : Mat3) (G V : Conn) (dV : ConnJet)
    (Lambda : Int) (hRight : mul g B = M1)
    (root : VolumeRoot g h)
    (ht : ∀ m a b, G m a b = G m b a) :
    root.v * EHvariationWithPalatini root.v root.dv B h Ric G V dV Lambda +
    root.v * EHvariationWithPalatini root.v root.dv B h Ric G V dV Lambda =
      determinant g *
      (traceProduct B h * (scalarCurvature B Ric - 2*Lambda) +
       2*(covariantDivergenceCurrent B G V
           (compatibleInverseJet B G) dV -
          traceProduct (mul B (mul h B)) Ric)) := by
  have hEH := curved_EH_density_first_variation
    g B h Ric (ricciDifferentialAddressed G V dV) Lambda hRight root
  dsimp only [EHvariationWithPalatini]
  rw [contracted_Ricci_trace_is_divergence B G V dV ht] at hEH
  exact hEH

-- At a closed/falloff-controlled smooth slice, the divergence term
-- integrates to its boundary flux. In the formal pointwise setting we
-- preserve it as an explicit additive residual.
def curvatureBulk (B h Ric : Mat3) (Lambda : Int) : Int :=
  traceProduct B h * (scalarCurvature B Ric - 2*Lambda) -
  2*traceProduct (mul B (mul h B)) Ric

def curvatureFlux (B : Mat3) (G V : Conn) (dV : ConnJet) : Int :=
  2*covariantDivergenceCurrent B G V (compatibleInverseJet B G) dV

theorem EH_bulk_plus_flux_exact
    (B h Ric : Mat3) (G V : Conn) (dV : ConnJet)
    (Lambda : Int) :
    curvatureBulk B h Ric Lambda + curvatureFlux B G V dV =
      traceProduct B h * (scalarCurvature B Ric - 2*Lambda) +
        2*(covariantDivergenceCurrent B G V
            (compatibleInverseJet B G) dV -
           traceProduct (mul B (mul h B)) Ric) := by
  simp only [curvatureBulk, curvatureFlux]
  omega

#print axioms trace_curvature_address_identity
#print axioms contracted_Ricci_trace_is_divergence
#print axioms curved_EH_variation_with_Palatini_flux
#print axioms EH_bulk_plus_flux_exact

end CurvedEHVariation010j
