import Init.Data.Rat.Basic
import proofs.SmoothTransport010o

/-!
# Minimum Mechanics 010o — two-sector canonical cotangent-lift theorem

Constructs an ACTUAL canonical symplectic bracket from the gradients of
the momentum map D[v]=<p,T_v q>.  The fields q,p may be smooth metric
tensors / momentum densities or smooth U(1) potential / electric densities.
This module is polymorphic in those types and intentionally does not
replace them with a finite-grid surrogate.

A cotangent transport representation supplies only two source properties:
  1. Adjoint duality <T_v* p,h>=<p,T_v h>.
  2. Lie representation T_u T_v - T_v T_u = T_[u,v] in the pairing.

They are ordinary analytic/geometric conditions and are NOT themselves
Poisson-bracket identities.

The canonical symplectic gradient-pairing then PROVES:
  {D[u],D[v]}=D[[u,v]]
  {D[v],G[s]}=G[T_v s]
  {G[s],G[t]}=0.
The second and third statements apply to the EM affine gauge momentum
map G[s]=<E,s>. The sum of two independent cotangent sectors obeys
the same D-D commutator (metric and electromagnetic terms).

This is the exact abstract cotangent theorem. A concrete C∞ tensor
bundle, its weak symplectic form and boundary domains must instantiate
the pairing/adjoint and the Lie representation before the physical
smooth Einstein–Maxwell conclusion is certified.

No new axioms, no sorry, no Mathlib, Lean 4.33.0.
-/
set_option autoImplicit false

namespace CotangentLift010o

structure CotangentSlice (F V : Type)
    (comm : V → V → V) where
  pair : F → F → Int
  zero : F
  transport : V → F → F
  adjoint : V → F → F
  pairSymm : ∀ a b, pair a b = pair b a
  pairZeroLeft : ∀ a, pair zero a = 0
  pairZeroRight : ∀ a, pair a zero = 0
  adjointDual : ∀ v p q,
    pair (adjoint v p) q = pair p (transport v q)
  pairedLie : ∀ u v p q,
    pair p (transport u (transport v q)) -
    pair p (transport v (transport u q)) =
      pair p (transport (comm u v) q)

def D {F V : Type} {comm : V → V → V}
    (S : CotangentSlice F V comm) (u : V) (q p : F) : Int :=
  S.pair p (S.transport u q)

-- The q-gradient is the formal adjoint T_u* p.
-- The p-gradient is T_u q; both follow from differentiating <p,Tq>.
def gradDq {F V : Type} {comm : V → V → V}
    (S : CotangentSlice F V comm) (u : V) (p : F) : F :=
  S.adjoint u p

def gradDp {F V : Type} {comm : V → V → V}
    (S : CotangentSlice F V comm) (u : V) (q : F) : F :=
  S.transport u q

def canonicalPB {F V : Type} {comm : V → V → V}
    (S : CotangentSlice F V comm)
    (fq fp gq gp : F) : Int :=
  S.pair fq gp-S.pair fp gq

def bracketDD {F V : Type} {comm : V → V → V}
    (S : CotangentSlice F V comm)
    (u v : V) (q p : F) : Int :=
  canonicalPB S (gradDq S u p) (gradDp S u q)
    (gradDq S v p) (gradDp S v q)

-- Direct canonical cotangent-lift bracket, with no D-D closure axiom.
theorem cotangent_DD_closure {F V : Type}
    {comm : V → V → V}
    (S : CotangentSlice F V comm)
    (u v : V) (q p : F) :
    bracketDD S u v q p = D S (comm u v) q p := by
  simp only [bracketDD, canonicalPB, gradDq, gradDp, D]
  rw [S.adjointDual u p (S.transport v q),
      S.pairSymm (S.transport u q) (S.adjoint v p),
      S.adjointDual v p (S.transport u q)]
  exact S.pairedLie u v p q

def G {F V : Type} {comm : V → V → V}
    (S : CotangentSlice F V comm) (s p : F) : Int :=
  S.pair p s

-- The affine momentum-shift gauge functional G[s]=<p,s> has
-- canonical gradients (0,s), not independently assigned PB outputs.
def bracketDG {F V : Type} {comm : V → V → V}
    (S : CotangentSlice F V comm)
    (u : V) (s q p : F) : Int :=
  canonicalPB S (gradDq S u p) (gradDp S u q) S.zero s

def bracketGG {F V : Type} {comm : V → V → V}
    (S : CotangentSlice F V comm) (s t : F) : Int :=
  canonicalPB S S.zero s S.zero t

theorem cotangent_DG_closure {F V : Type}
    {comm : V → V → V}
    (S : CotangentSlice F V comm)
    (u : V) (s q p : F) :
    bracketDG S u s q p = G S (S.transport u s) p := by
  simp only [bracketDG, canonicalPB, gradDq, gradDp, G]
  rw [S.pairZeroRight, S.adjointDual u p s]
  omega

theorem cotangent_GG_closure {F V : Type}
    {comm : V → V → V}
    (S : CotangentSlice F V comm)
    (s t : F) :
    bracketGG S s t = 0 := by
  simp only [bracketGG, canonicalPB]
  rw [S.pairZeroLeft, S.pairZeroRight]
  omega

-- The two independent canonical sectors have no cross Poisson bracket.
structure TwoSectors (FG FE V : Type)
    (comm : V → V → V) where
  gravity : CotangentSlice FG V comm
  electromagnetic : CotangentSlice FE V comm

def combinedD {FG FE V : Type} {comm : V → V → V}
    (S : TwoSectors FG FE V comm)
    (v : V) (gamma pi : FG) (A E : FE) : Int :=
  D S.gravity v gamma pi + D S.electromagnetic v A E

def combinedDD {FG FE V : Type} {comm : V → V → V}
    (S : TwoSectors FG FE V comm)
    (u v : V) (gamma pi : FG) (A E : FE) : Int :=
  bracketDD S.gravity u v gamma pi +
  bracketDD S.electromagnetic u v A E

theorem two_sector_DD_closure {FG FE V : Type}
    {comm : V → V → V}
    (S : TwoSectors FG FE V comm)
    (u v : V) (gamma pi : FG) (A E : FE) :
    combinedDD S u v gamma pi A E =
      combinedD S (comm u v) gamma pi A E := by
  simp only [combinedDD, combinedD]
  rw [cotangent_DD_closure, cotangent_DD_closure]

-- The gauge generator acts only on the EM canonical pair, while the
-- gravitational canonical sector commutes by independent pairing.
theorem two_sector_DG_closure {FG FE V : Type}
    {comm : V → V → V}
    (S : TwoSectors FG FE V comm)
    (v : V) (s A E : FE) :
    bracketDG S.electromagnetic v s A E =
      G S.electromagnetic (S.electromagnetic.transport v s) E :=
  cotangent_DG_closure S.electromagnetic v s A E

theorem two_sector_GG_closure {FG FE V : Type}
    {comm : V → V → V}
    (S : TwoSectors FG FE V comm)
    (s t : FE) :
    bracketGG S.electromagnetic s t = 0 :=
  cotangent_GG_closure S.electromagnetic s t

#print axioms cotangent_DD_closure
#print axioms cotangent_DG_closure
#print axioms cotangent_GG_closure
#print axioms two_sector_DD_closure
#print axioms two_sector_DG_closure
#print axioms two_sector_GG_closure

end CotangentLift010o
