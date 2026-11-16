import Init.Data.Rat.Basic
import proofs.CotangentLift010o
import proofs.ImprovedMaxwell010o

/-!
# Minimum Mechanics 010o — ONE canonical four-field functional Poisson bracket

The four canonical types are (γ,π;A,E), with metric/momentum fields
from FG and Maxwell potential/electric-density fields from FE.
Their first variations form a single typed Gradient record.

The canonical functional Poisson bracket is DEFINED from the two
cotangent pairings, with the six independent symmetric-metric
coordinates represented by FG (off-diagonal conjugates have their
proper canonical normalization in a concrete implementation).

In particular, this is ONE symplectic bracket, not six independently
postulated bracket operators:
  {F,G} = <F_γ,G_π>-<F_π,G_γ>+<F_A,G_E>-<F_E,G_A>.

The spatial generator D[v]=<π,T_vγ>+<E,T_vA> has derived gradients
  (T_v* π, T_vγ; T_v*E,T_v A).
The gauge generator G[s]=<E,s> has gradients (0,0;0,s).

Lean proves all three canonical brackets
  {D[u],D[v]}=D[[u,v]],
  {D[v],G[s]}=G[T_v s],
  {G[s],G[t]}=0,
without admitting those brackets as assumptions.

It also proves canonical CHAIN-RULE identities for {D,H} and {G,H}
for an arbitrary differentiable functional H with supplied gradients.
H's geometric covariance and gauge invariance are independent
first-variation obligations: their concrete smooth-manifold
realization is retained OPEN.

FG/FE are abstract smooth field carriers requiring a concrete
cotangent-slice instantiation, not a finite Fourier surrogate. This
module therefore certifies the structural Poisson theorem conditional
on the two cotangent representation laws (adjoint duality and Lie
representation), and does NOT claim a constructed Banach/Fréchet
phase space.

No new axioms, sorry or Mathlib. Lean 4.33.0.
-/
set_option autoImplicit false

namespace SinglePoisson010o

open CotangentLift010o

structure Gradient (FG FE : Type) where
  dGamma : FG
  dPi : FG
  dA : FE
  dE : FE

def canonicalPB {FG FE V : Type} {comm : V → V → V}
    (S : TwoSectors FG FE V comm)
    (f g : Gradient FG FE) : Int :=
  S.gravity.pair f.dGamma g.dPi -
    S.gravity.pair f.dPi g.dGamma +
  S.electromagnetic.pair f.dA g.dE -
    S.electromagnetic.pair f.dE g.dA

theorem canonicalPB_antisymmetric {FG FE V : Type}
    {comm : V → V → V}
    (S : TwoSectors FG FE V comm)
    (f g : Gradient FG FE) :
    canonicalPB S f g = -canonicalPB S g f := by
  simp only [canonicalPB]
  rw [S.gravity.pairSymm f.dGamma g.dPi,
      S.gravity.pairSymm f.dPi g.dGamma,
      S.electromagnetic.pairSymm f.dA g.dE,
      S.electromagnetic.pairSymm f.dE g.dA]
  omega

def spatialGradient {FG FE V : Type} {comm : V → V → V}
    (S : TwoSectors FG FE V comm)
    (v : V) (gamma pi : FG) (A E : FE) : Gradient FG FE :=
  ⟨S.gravity.adjoint v pi,
   S.gravity.transport v gamma,
   S.electromagnetic.adjoint v E,
   S.electromagnetic.transport v A⟩

def gaussGradient {FG FE V : Type} {comm : V → V → V}
    (S : TwoSectors FG FE V comm) (s : FE) : Gradient FG FE :=
  ⟨S.gravity.zero,S.gravity.zero,
   S.electromagnetic.zero,s⟩

def pbDD {FG FE V : Type} {comm : V → V → V}
    (S : TwoSectors FG FE V comm)
    (u v : V) (gamma pi : FG) (A E : FE) : Int :=
  canonicalPB S (spatialGradient S u gamma pi A E)
                (spatialGradient S v gamma pi A E)

def pbDG {FG FE V : Type} {comm : V → V → V}
    (S : TwoSectors FG FE V comm)
    (v : V) (s : FE) (gamma pi : FG) (A E : FE) : Int :=
  canonicalPB S (spatialGradient S v gamma pi A E)
                (gaussGradient S s)

def pbGG {FG FE V : Type} {comm : V → V → V}
    (S : TwoSectors FG FE V comm) (s t : FE) : Int :=
  canonicalPB S (gaussGradient S s) (gaussGradient S t)

theorem singlePB_DD {FG FE V : Type} {comm : V → V → V}
    (S : TwoSectors FG FE V comm)
    (u v : V) (gamma pi : FG) (A E : FE) :
    pbDD S u v gamma pi A E =
      combinedD S (comm u v) gamma pi A E := by
  simp only [pbDD, canonicalPB, spatialGradient, combinedD,
    CotangentLift010o.D, CotangentLift010o.bracketDD,
    CotangentLift010o.canonicalPB, CotangentLift010o.gradDq,
    CotangentLift010o.gradDp]
  have hg := cotangent_DD_closure S.gravity u v gamma pi
  have he := cotangent_DD_closure S.electromagnetic u v A E
  dsimp [CotangentLift010o.bracketDD,
    CotangentLift010o.canonicalPB, CotangentLift010o.gradDq,
    CotangentLift010o.gradDp, CotangentLift010o.D] at hg he
  omega

theorem singlePB_DG {FG FE V : Type} {comm : V → V → V}
    (S : TwoSectors FG FE V comm)
    (v : V) (s : FE) (gamma pi : FG) (A E : FE) :
    pbDG S v s gamma pi A E =
      G S.electromagnetic (S.electromagnetic.transport v s) E := by
  simp only [pbDG, canonicalPB, spatialGradient, gaussGradient]
  rw [S.gravity.pairZeroRight, S.gravity.pairZeroRight,
      S.electromagnetic.pairZeroRight]
  simp only [sub_zero, zero_add]
  exact cotangent_DG_closure S.electromagnetic v s A E

theorem singlePB_GG {FG FE V : Type} {comm : V → V → V}
    (S : TwoSectors FG FE V comm) (s t : FE) :
    pbGG S s t = 0 := by
  simp only [pbGG, canonicalPB, gaussGradient]
  rw [S.gravity.pairZeroLeft, S.gravity.pairZeroRight,
      S.electromagnetic.pairZeroLeft,
      S.electromagnetic.pairZeroRight]
  omega

-- The actual variation of H under spatial Lie transport of all
-- four canonical fields, expressed in the canonical gradient pairing.
def firstVariationUnderD {FG FE V : Type} {comm : V → V → V}
    (S : TwoSectors FG FE V comm)
    (v : V) (gamma pi : FG) (A E : FE)
    (h : Gradient FG FE) : Int :=
  S.gravity.pair h.dGamma (S.gravity.transport v gamma) -
  S.gravity.pair h.dPi (S.gravity.adjoint v pi) +
  S.electromagnetic.pair h.dA (S.electromagnetic.transport v A) -
  S.electromagnetic.pair h.dE (S.electromagnetic.adjoint v E)

theorem singlePB_DH_chain_rule {FG FE V : Type}
    {comm : V → V → V}
    (S : TwoSectors FG FE V comm)
    (v : V) (gamma pi : FG) (A E : FE)
    (h : Gradient FG FE) :
    canonicalPB S (spatialGradient S v gamma pi A E) h =
      -firstVariationUnderD S v gamma pi A E h := by
  simp only [canonicalPB, spatialGradient, firstVariationUnderD]
  rw [S.gravity.pairSymm (S.gravity.adjoint v pi) h.dPi,
      S.gravity.pairSymm (S.gravity.transport v gamma) h.dGamma,
      S.electromagnetic.pairSymm (S.electromagnetic.adjoint v E) h.dE,
      S.electromagnetic.pairSymm (S.electromagnetic.transport v A) h.dA]
  omega

-- Gauge invariance of H is a FIRST VARIATION statement involving
-- only its A-gradient; the canonical G–H Poisson reduction is proved.
def gaugeResponse {FG FE V : Type} {comm : V → V → V}
    (S : TwoSectors FG FE V comm)
    (s : FE) (h : Gradient FG FE) : Int :=
  S.electromagnetic.pair h.dA s

theorem singlePB_GH_reduction {FG FE V : Type}
    {comm : V → V → V}
    (S : TwoSectors FG FE V comm)
    (s : FE) (h : Gradient FG FE) :
    canonicalPB S (gaussGradient S s) h =
      -gaugeResponse S s h := by
  simp only [canonicalPB, gaussGradient, gaugeResponse]
  rw [S.gravity.pairZeroLeft, S.gravity.pairZeroLeft,
      S.electromagnetic.pairZeroLeft,
      S.electromagnetic.pairSymm s h.dA]
  omega

theorem singlePB_GH_if_gauge_variation_zero {FG FE V : Type}
    {comm : V → V → V}
    (S : TwoSectors FG FE V comm)
    (s : FE) (h : Gradient FG FE)
    (hGauge : gaugeResponse S s h = 0) :
    canonicalPB S (gaussGradient S s) h = 0 := by
  rw [singlePB_GH_reduction, hGauge]
  omega

#print axioms canonicalPB_antisymmetric
#print axioms singlePB_DD
#print axioms singlePB_DG
#print axioms singlePB_GG
#print axioms singlePB_DH_chain_rule
#print axioms singlePB_GH_reduction
#print axioms singlePB_GH_if_gauge_variation_zero

end SinglePoisson010o
