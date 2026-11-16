import Init.Data.Rat.Basic
import proofs.FourierDiffeo010l

/-!
# Minimum Mechanics 010l — finite Fourier gauge/transport constraint ledger

This certifies finite-support linear combinations of the three-dimensional
vector-field Fourier modes from FourierDiffeo010l. It proves Jacobi and the
D–D–G semidirect representation law for arbitrary finite mode lists,
without imposing a finite mode cutoff (which would destroy closure).

Gauss/Gauge and scalar-lapse modes are kept as different typed offices:
both transform as scalars, but only GaugeMode carries the abelian gauge
generator. The Hamiltonian constraint H[N] is NOT identified with the
scalar-lapse type: its genuine canonical functional bracket remains OPEN.

All sums are exact finite integer sums; no analytic completion, smooth
spatial manifold, or C∞ field functional is claimed. No new axioms or sorry.
-/
set_option autoImplicit false
namespace FourierConstraints010l
open FourierDiffeo010l

abbrev V := V3

def sumVec : List V → V
  | [] => zero
  | x :: xs => add x (sumVec xs)

private theorem sumVec_map_zero {α : Type}
    (xs : List α) (f : α → V)
    (hf : ∀ x, f x = zero) :
    sumVec (xs.map f) = zero := by
  induction xs with
  | nil => rfl
  | cons x rest ih =>
    change add (f x) (sumVec (rest.map f)) = zero
    rw [hf x, ih]
    rfl

def jacobiAmplitude (A B C : VectorMode) : V :=
  add (add (vectorBracket (vectorBracket A B) C).u
           (vectorBracket (vectorBracket B C) A).u)
           (vectorBracket (vectorBracket C A) B).u

theorem jacobi_amplitude_zero (A B C : VectorMode) :
    jacobiAmplitude A B C = zero :=
  vector_jacobi A B C

def finiteVectorJacobi
    (as bs cs : List VectorMode) : V :=
  sumVec (as.map (fun a =>
    sumVec (bs.map (fun b =>
      sumVec (cs.map (fun c =>
        jacobiAmplitude a b c))))))

theorem finite_fourier_vector_jacobi
    (as bs cs : List VectorMode) :
    finiteVectorJacobi as bs cs = zero := by
  unfold finiteVectorJacobi
  apply sumVec_map_zero
  intro a
  apply sumVec_map_zero
  intro b
  apply sumVec_map_zero
  intro c
  exact jacobi_amplitude_zero a b c

def scalarSemidirectResidual
    (A B : VectorMode) (g : ScalarMode) : Int :=
  (scalarAction A (scalarAction B g)).a -
  (scalarAction B (scalarAction A g)).a -
  (scalarAction (vectorBracket A B) g).a

theorem scalar_residual_zero (A B : VectorMode)
    (g : ScalarMode) :
    scalarSemidirectResidual A B g = 0 := by
  simp only [scalarSemidirectResidual]
  have h := scalar_semidirect_law A B g
  omega

private theorem sumInt_map_zero {α : Type}
    (xs : List α) (f : α → Int)
    (hf : ∀ x, f x = 0) :
    (xs.map f).sum = 0 := by
  induction xs with
  | nil => simp
  | cons x rest ih =>
    simp only [List.map_cons, List.sum_cons]
    rw [hf x, ih]
    omega

def finiteScalarSemidirect
    (as bs : List VectorMode) (gs : List ScalarMode) : Int :=
  (as.map (fun a =>
    (bs.map (fun b =>
      (gs.map (fun g => scalarSemidirectResidual a b g)).sum
    )).sum
  )).sum

theorem finite_fourier_semidirect
    (as bs : List VectorMode) (gs : List ScalarMode) :
    finiteScalarSemidirect as bs gs = 0 := by
  unfold finiteScalarSemidirect
  apply sumInt_map_zero
  intro a
  apply sumInt_map_zero
  intro b
  apply sumInt_map_zero
  intro g
  exact scalar_residual_zero a b g

structure GaugeMode where
  mode : ScalarMode
  deriving DecidableEq, Repr

structure LapseMode where
  mode : ScalarMode
  deriving DecidableEq, Repr

def transportGauge (A : VectorMode) (G : GaugeMode) : GaugeMode :=
  ⟨scalarAction A G.mode⟩

def transportLapse (A : VectorMode) (N : LapseMode) : LapseMode :=
  ⟨scalarAction A N.mode⟩

theorem gauge_action_transport
    (A B : VectorMode) (G : GaugeMode) :
    (transportGauge A (transportGauge B G)).mode.a -
    (transportGauge B (transportGauge A G)).mode.a =
    (transportGauge (vectorBracket A B) G).mode.a := by
  exact scalar_semidirect_law A B G.mode

theorem lapse_action_transport
    (A B : VectorMode) (N : LapseMode) :
    (transportLapse A (transportLapse B N)).mode.a -
    (transportLapse B (transportLapse A N)).mode.a =
    (transportLapse (vectorBracket A B) N).mode.a := by
  exact scalar_semidirect_law A B N.mode

def gaugePB (_ _ : GaugeMode) : Int := 0

theorem abelian_gauss (G H : GaugeMode) : gaugePB G H = 0 := rfl

-- The genuine ADM Hamiltonian functional bracket will require the
-- dynamical spatial metric, canonical momenta, and field-functional PB.
-- No surrogate Hamiltonian bracket is introduced here.

#print axioms finite_fourier_vector_jacobi
#print axioms scalar_residual_zero
#print axioms finite_fourier_semidirect
#print axioms gauge_action_transport
#print axioms lapse_action_transport
#print axioms abelian_gauss

end FourierConstraints010l
