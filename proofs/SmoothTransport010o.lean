import Init.Data.Rat.Basic
import proofs.DoubleStokes010l

/-!
# Minimum Mechanics 010o — covariant scalar-density transport seam

Jurisdiction: an arbitrary spatial three-direction differential algebra
with a supplied Stokes/boundary calculus and explicit commutative-product
laws. This is not a finite-mode surrogate. F is an abstract carrier of
smooth coefficient fields to be instantiated by a genuine smooth slice.

Let rho be a scalar density and v a spatial vector descriptor.
Define its Lie transport as div(v rho), and the scalar lapse transport
L_v N = v^i D_i N. Hamiltonian H[N] := I(N rho).

With zero boundary flux the derivative of H[N] along the canonical
spatial-diffeomorphism flow obeys
  -I(N L_v rho) = H[L_v N].
The result is derived from Leibniz and Stokes, not a pre-declared
D-H bracket.

The same theorem applies to the Gauss density as a weight-one scalar
density. The interface from this flow to the infinite-dimensional
symplectic Poisson bracket is *explicitly separate*. This theorem is
the density-transport piece of ADM closure, not a proof that a
concrete smooth manifold has been instantiated.

No sorry, no new axioms, no Mathlib. Lean 4.33.0.
-/

set_option autoImplicit false

namespace SmoothTransport010o

abbrev Axis := Fin 3

-- The inherited boundary calculus already supplies the product rule,
-- integral additivity, and the boundary version of Stokes.
structure SmoothSlice (F : Type) where
  s : PalatiniBoundary010i.BoundarySlice F
  mulAssoc : ∀ a b c : F,
    s.mulField (s.mulField a b) c =
      s.mulField a (s.mulField b c)
  mulComm : ∀ a b : F, s.mulField a b = s.mulField b a
  mulAdd : ∀ a b c : F,
    s.mulField a (s.addField b c) =
      s.addField (s.mulField a b) (s.mulField a c)
  addMul : ∀ a b c : F,
    s.mulField (s.addField a b) c =
      s.addField (s.mulField a c) (s.mulField b c)

def lieScalar {F : Type}
    (S : SmoothSlice F) (v : Axis → F) (N : F) : F :=
  S.s.addField
    (S.s.addField
      (S.s.mulField (v 0) (S.s.deriv 0 N))
      (S.s.mulField (v 1) (S.s.deriv 1 N)))
    (S.s.mulField (v 2) (S.s.deriv 2 N))

def lieDensity {F : Type}
    (S : SmoothSlice F) (v : Axis → F) (rho : F) : F :=
  S.s.addField
    (S.s.addField
      (S.s.deriv 0 (S.s.mulField (v 0) rho))
      (S.s.deriv 1 (S.s.mulField (v 1) rho)))
    (S.s.deriv 2 (S.s.mulField (v 2) rho))

def smeared {F : Type}
    (S : SmoothSlice F) (N rho : F) : Int :=
  S.s.integral (S.s.mulField N rho)

-- The canonical D-action on a scalar density is the Lie derivative.
-- 'densityFlow' is the *variation*, not defined as a Poisson bracket.
def densityFlow {F : Type}
    (S : SmoothSlice F) (v : Axis → F) (N rho : F) : Int :=
  -(smeared S N (lieDensity S v rho))

-- An algebraic identity that identifies how integration-by-parts
-- transports a lapse through one directional flux.
theorem stokes_direction {F : Type}
    (S : SmoothSlice F) (v : Axis → F)
    (N rho : F) (i : Axis)
    (hBoundary : S.s.boundary i
      (S.s.mulField N (S.s.mulField (v i) rho)) = 0) :
    -(S.s.integral
        (S.s.mulField N (S.s.deriv i (S.s.mulField (v i) rho)))) =
      S.s.integral
        (S.s.mulField (S.s.mulField (v i) (S.s.deriv i N)) rho) := by
  have hs := PalatiniBoundary010i.weighted_boundary_integration_by_parts
    S.s i N (S.s.mulField (v i) rho)
  rw [hBoundary] at hs
  have hmul :
      S.s.mulField (S.s.deriv i N) (S.s.mulField (v i) rho) =
      S.s.mulField (S.s.mulField (v i) (S.s.deriv i N)) rho := by
    calc
      S.s.mulField (S.s.deriv i N) (S.s.mulField (v i) rho) =
        S.s.mulField (S.s.mulField (S.s.deriv i N) (v i)) rho :=
          (S.mulAssoc _ _ _).symm
      _ = S.s.mulField (S.s.mulField (v i) (S.s.deriv i N)) rho := by
        rw [S.mulComm (S.s.deriv i N) (v i)]
  rw [hmul] at hs
  omega

-- Three transported terms have exact and visible offices.
theorem density_flow_expands {F : Type}
    (S : SmoothSlice F) (v : Axis → F) (N rho : F) :
    densityFlow S v N rho =
      -(S.s.integral
          (S.s.mulField N (S.s.deriv 0 (S.s.mulField (v 0) rho))) +
        S.s.integral
          (S.s.mulField N (S.s.deriv 1 (S.s.mulField (v 1) rho))) +
        S.s.integral
          (S.s.mulField N (S.s.deriv 2 (S.s.mulField (v 2) rho)))) := by
  simp only [densityFlow, smeared, lieDensity]
  rw [S.mulAdd, S.mulAdd, S.s.integral_add, S.s.integral_add]

theorem smeared_lie_scalar_expands {F : Type}
    (S : SmoothSlice F) (v : Axis → F) (N rho : F) :
    smeared S (lieScalar S v N) rho =
      S.s.integral
        (S.s.mulField (S.s.mulField (v 0) (S.s.deriv 0 N)) rho) +
      S.s.integral
        (S.s.mulField (S.s.mulField (v 1) (S.s.deriv 1 N)) rho) +
      S.s.integral
        (S.s.mulField (S.s.mulField (v 2) (S.s.deriv 2 N)) rho) := by
  simp only [smeared, lieScalar]
  rw [S.addMul, S.addMul, S.s.integral_add, S.s.integral_add]

-- A proved D-H density-transport relation, under *boundary*
-- hypotheses rather than assuming D-H as an input theorem.
theorem density_transport_identity {F : Type}
    (S : SmoothSlice F) (v : Axis → F) (N rho : F)
    (hBoundary : ∀ i : Axis,
      S.s.boundary i (S.s.mulField N
        (S.s.mulField (v i) rho)) = 0) :
    densityFlow S v N rho =
      smeared S (lieScalar S v N) rho := by
  rw [density_flow_expands, smeared_lie_scalar_expands]
  have h0 := stokes_direction S v N rho 0 (hBoundary 0)
  have h1 := stokes_direction S v N rho 1 (hBoundary 1)
  have h2 := stokes_direction S v N rho 2 (hBoundary 2)
  omega

-- Two typed offices: scalar Hamiltonian density and Gauss density.
-- They share the weight-one density transport law.
structure Densities (F : Type) where
  hDensity : F
  gaussDensity : F

theorem Hamiltonian_density_transport {F : Type}
    (S : SmoothSlice F) (v : Axis → F) (N : F)
    (rho : Densities F)
    (hBoundary : ∀ i : Axis,
      S.s.boundary i (S.s.mulField N
        (S.s.mulField (v i) rho.hDensity)) = 0) :
    densityFlow S v N rho.hDensity =
      smeared S (lieScalar S v N) rho.hDensity :=
  density_transport_identity S v N rho.hDensity hBoundary

theorem Gauss_density_transport {F : Type}
    (S : SmoothSlice F) (v : Axis → F) (alpha : F)
    (rho : Densities F)
    (hBoundary : ∀ i : Axis,
      S.s.boundary i (S.s.mulField alpha
        (S.s.mulField (v i) rho.gaussDensity)) = 0) :
    densityFlow S v alpha rho.gaussDensity =
      smeared S (lieScalar S v alpha) rho.gaussDensity :=
  density_transport_identity S v alpha rho.gaussDensity hBoundary

#print axioms stokes_direction
#print axioms density_flow_expands
#print axioms smeared_lie_scalar_expands
#print axioms density_transport_identity
#print axioms Hamiltonian_density_transport
#print axioms Gauss_density_transport

end SmoothTransport010o
