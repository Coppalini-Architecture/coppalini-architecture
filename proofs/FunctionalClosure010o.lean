import Init.Data.Rat.Basic
import proofs.SinglePoisson010o
import proofs.ADMFunctional010d

/-!
# Minimum Mechanics 010o — ONE conditional six-bracket functional ledger

This is the requested end-to-end *proof interface*, not a declaration of
unconditional smooth Einstein–Maxwell first-class certification.

The canonical bracket for ALL six relations is the SAME four-field
symplectic tensor defined and kernel-checked in SinglePoisson010o.
Three relations D-D, D-G, G-G follow by genuine cotangent-lift algebra.
The D-H relation follows from the proved SmoothTransport010o Stokes
calculus and its explicit first-variation naturality seam.
G-H follows from the Maxwell gauge first-variation seam.
H-H follows from the 010b–010d normal-current reduction, plus two
explicit bridge witnesses tying those already-verified cell calculations
to the physical smooth functional gradient and metric-dependent shift.

The bridge DOES NOT assume the final six bracket equations. It
requires source facts of DIFFERENT type:

* gaugeHamiltonianVariationZero (gauge derivative of H);
* hDensityCovariance (the total H first variation under actual D-flow);
* gaussSmearingCovariance (the gradient parameter transforms correctly);
* sourceNormalGradient (smooth H-H gradients match the certified
  gravitational and electromagnetic normal integrands);
* sourceMomentumAddress (the current reduces to the correctly improved
  metric-dependent momentum generator);
* zero integrated curvature-current flux.

These are valid sufficient conditions. Their concrete C∞
Einstein–Maxwell–ADM realization is not yet certified by this file:
the incomplete interface is a named OPEN, rather than a silent axiom.
The Gauss improvement in the H-H relation is NOT discarded.

All mathematical equalities in this module are proved in Lean
from the fields above, and require no sorry or new axioms.

This is the exact dependency theorem to be instantiated in a
subsequent *smooth geometric realization*; the standard classical
Einstein–Maxwell algebra itself is mathematically known.
-/
set_option autoImplicit false

namespace FunctionalClosure010o

open CotangentLift010o SinglePoisson010o SmoothTransport010o

abbrev Axis := Fin 3

structure SmoothCompletion (FG FE V F : Type)
    (comm : V → V → V) where
  canon : TwoSectors FG FE V comm
  smooth : SmoothSlice F
  descriptor : V → Axis → F
  gamma : FG
  pi : FG
  A : FE
  E : FE
  hDensity : F
  gaussDensity : F
  hGradient : F → Gradient FG FE
  gaussTest : F → FE
  metricShift : F → F → V
  gaugeCorrection : F → F → FE
  gravityCells : F → F → List ADMFunctional010d.NormalCell
  maxwellCells : F → F → List Maxwell010b.Cell

  -- Independent first-variation naturality of the H density:
  -- this is a geometric chain-rule condition, not the D-H bracket.
  hDensityCovariance : ∀ v N,
    firstVariationUnderD canon v gamma pi A E (hGradient N) =
    smeared smooth N (lieDensity smooth (descriptor v) hDensity)

  -- The Maxwell A-gradient annihilates a pure-gauge direction.
  gaugeHamiltonianVariationZero : ∀ alpha N,
    gaugeResponse canon (gaussTest alpha) (hGradient N) = 0

  -- The gauge smearing has the correct covariant transport address.
  gaussSmearingCovariance : ∀ v alpha,
    canon.electromagnetic.transport v (gaussTest alpha) =
      gaussTest (lieScalar smooth (descriptor v) alpha)

  -- Zero boundary flux for scalar density Stokes transfer.
  boundaryH : ∀ v N i,
    smooth.s.boundary i
      (smooth.s.mulField N
        (smooth.s.mulField (descriptor v i) hDensity)) = 0

  -- This is the main not-yet-instantiated smooth functional gradient
  -- map from the exact ADM first variations onto the canonical Poisson
  -- tensor. Do NOT confuse it with a generic axiomatization of closure.
  sourceNormalGradient : ∀ N M,
    canonicalPB canon (hGradient N) (hGradient M) =
      ADMFunctional010d.combinedNormalBracket
        (gravityCells N M) (maxwellCells N M)

  -- The same specific physical 3-metric inverse determines w from
  -- N∂M-M∂N. This is the remaining normal-current address transport.
  sourceMomentumAddress : ∀ N M,
    ADMFunctional010d.combinedMomentum
      (gravityCells N M) (maxwellCells N M) =
    combinedD canon (metricShift N M) gamma pi A E -
      G canon.electromagnetic (gaugeCorrection N M) E

  -- The integrated total curvature-current boundary flux vanishes.
  boundaryNormal : ∀ N M,
    ADMFunctional010d.sumCells
      (gravityCells N M) ADMFunctional010d.gravCurrentDivergence = 0

def D {FG FE V F : Type} {comm : V → V → V}
    (C : SmoothCompletion FG FE V F comm) (v : V) : Int :=
  combinedD C.canon v C.gamma C.pi C.A C.E

def Gc {FG FE V F : Type} {comm : V → V → V}
    (C : SmoothCompletion FG FE V F comm) (alpha : F) : Int :=
  G C.canon.electromagnetic (C.gaussTest alpha) C.E

def H {FG FE V F : Type} {comm : V → V → V}
    (C : SmoothCompletion FG FE V F comm) (N : F) : Int :=
  smeared C.smooth N C.hDensity

def bracketDD {FG FE V F : Type} {comm : V → V → V}
    (C : SmoothCompletion FG FE V F comm) (u v : V) : Int :=
  pbDD C.canon u v C.gamma C.pi C.A C.E

def bracketDG {FG FE V F : Type} {comm : V → V → V}
    (C : SmoothCompletion FG FE V F comm) (v : V) (alpha : F) : Int :=
  pbDG C.canon v (C.gaussTest alpha) C.gamma C.pi C.A C.E

def bracketGG {FG FE V F : Type} {comm : V → V → V}
    (C : SmoothCompletion FG FE V F comm) (alpha beta : F) : Int :=
  pbGG C.canon (C.gaussTest alpha) (C.gaussTest beta)

def bracketDH {FG FE V F : Type} {comm : V → V → V}
    (C : SmoothCompletion FG FE V F comm) (v : V) (N : F) : Int :=
  canonicalPB C.canon
    (spatialGradient C.canon v C.gamma C.pi C.A C.E)
    (C.hGradient N)

def bracketGH {FG FE V F : Type} {comm : V → V → V}
    (C : SmoothCompletion FG FE V F comm) (alpha N : F) : Int :=
  canonicalPB C.canon
    (gaussGradient C.canon (C.gaussTest alpha))
    (C.hGradient N)

def bracketHH {FG FE V F : Type} {comm : V → V → V}
    (C : SmoothCompletion FG FE V F comm) (N M : F) : Int :=
  canonicalPB C.canon (C.hGradient N) (C.hGradient M)

-- The first three brackets need no curvature functional premises:
-- they are fully derived from a single cotangent symplectic structure.
theorem gauge_gauge {FG FE V F : Type}
    {comm : V → V → V}
    (C : SmoothCompletion FG FE V F comm) (a b : F) :
    bracketGG C a b = 0 :=
  singlePB_GG C.canon (C.gaussTest a) (C.gaussTest b)

theorem diffeo_diffeo {FG FE V F : Type}
    {comm : V → V → V}
    (C : SmoothCompletion FG FE V F comm) (u v : V) :
    bracketDD C u v = D C (comm u v) :=
  singlePB_DD C.canon u v C.gamma C.pi C.A C.E

theorem diffeo_gauss {FG FE V F : Type}
    {comm : V → V → V}
    (C : SmoothCompletion FG FE V F comm) (v : V) (a : F) :
    bracketDG C v a =
      Gc C (lieScalar C.smooth (C.descriptor v) a) := by
  unfold bracketDG Gc
  rw [singlePB_DG]
  rw [C.gaussSmearingCovariance v a]

theorem gauss_hamiltonian {FG FE V F : Type}
    {comm : V → V → V}
    (C : SmoothCompletion FG FE V F comm) (a N : F) :
    bracketGH C a N = 0 := by
  unfold bracketGH
  exact singlePB_GH_if_gauge_variation_zero C.canon
    (C.gaussTest a) (C.hGradient N)
    (C.gaugeHamiltonianVariationZero a N)

theorem diffeo_hamiltonian {FG FE V F : Type}
    {comm : V → V → V}
    (C : SmoothCompletion FG FE V F comm) (v : V) (N : F) :
    bracketDH C v N =
      H C (lieScalar C.smooth (C.descriptor v) N) := by
  unfold bracketDH H
  rw [singlePB_DH_chain_rule]
  rw [C.hDensityCovariance v N]
  change densityFlow C.smooth (C.descriptor v) N C.hDensity =
    smeared C.smooth (lieScalar C.smooth (C.descriptor v) N)
      C.hDensity
  exact density_transport_identity C.smooth
    (C.descriptor v) N C.hDensity (C.boundaryH v N)

-- The normal–normal theorem is derived from the existing
-- 010d source-current identity plus the explicitly OPEN
-- smooth-gradient and metric-dependent momentum-address bridges.
theorem hamiltonian_hamiltonian {FG FE V F : Type}
    {comm : V → V → V}
    (C : SmoothCompletion FG FE V F comm) (N M : F) :
    bracketHH C N M =
      D C (C.metricShift N M) -
      G C.canon.electromagnetic (C.gaugeCorrection N M) C.E := by
  unfold bracketHH D
  calc
    canonicalPB C.canon (C.hGradient N) (C.hGradient M) =
      ADMFunctional010d.combinedNormalBracket
        (C.gravityCells N M) (C.maxwellCells N M) :=
          C.sourceNormalGradient N M
    _ = ADMFunctional010d.combinedMomentum
          (C.gravityCells N M) (C.maxwellCells N M) :=
      ADMFunctional010d.einstein_maxwell_normal_normal_conditional
        (C.gravityCells N M) (C.maxwellCells N M)
        (C.boundaryNormal N M)
    _ = combinedD C.canon (C.metricShift N M)
          C.gamma C.pi C.A C.E -
      G C.canon.electromagnetic (C.gaugeCorrection N M) C.E :=
        C.sourceMomentumAddress N M

-- ONE end-to-end theorem: all six secondary brackets, all using the
-- SAME four-field canonical Poisson tensor. The theorem is correctly
-- conditional on SmoothCompletion, whose noncircular geometric and
-- variational evidence must still be instantiated for C∞ ADM data.
theorem six_secondary_brackets {FG FE V F : Type}
    {comm : V → V → V}
    (C : SmoothCompletion FG FE V F comm) :
    (∀ a b : F, bracketGG C a b = 0) ∧
    (∀ a N : F, bracketGH C a N = 0) ∧
    (∀ v : V, ∀ a : F,
      bracketDG C v a =
        Gc C (lieScalar C.smooth (C.descriptor v) a)) ∧
    (∀ u v : V, bracketDD C u v = D C (comm u v)) ∧
    (∀ v : V, ∀ N : F,
      bracketDH C v N =
        H C (lieScalar C.smooth (C.descriptor v) N)) ∧
    (∀ N M : F,
      bracketHH C N M =
        D C (C.metricShift N M) -
        G C.canon.electromagnetic (C.gaugeCorrection N M) C.E) := by
  exact ⟨gauge_gauge C,
    gauss_hamiltonian C,
    diffeo_gauss C,
    diffeo_diffeo C,
    diffeo_hamiltonian C,
    hamiltonian_hamiltonian C⟩

#print axioms gauge_gauge
#print axioms diffeo_diffeo
#print axioms diffeo_gauss
#print axioms gauss_hamiltonian
#print axioms diffeo_hamiltonian
#print axioms hamiltonian_hamiltonian
#print axioms six_secondary_brackets

end FunctionalClosure010o
