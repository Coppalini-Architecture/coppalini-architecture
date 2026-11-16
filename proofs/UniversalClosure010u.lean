
import Init.Data.Rat.Basic
import proofs.PrimeRationalSymplectic010t
import YMGapRefusal010r
import proofs.FourierGradient010n
import proofs.QuadraticTransport010m
import proofs.FourierConstraints010l
import proofs.LinearTransport010f

/-!
# Minimum Mechanics 010u — universal *jurisdictional* closure

Fixed reference: all 010a–010t files remain unchanged. The import graph
includes the previously separate canonical/Fourier and Yang–Mills refusal
branches. This file proves a universally quantified recognition/return
contract over arbitrary declared carriers, not a universal physical theory.

The five-layer AxiomaticBuild summary/README (Lean v4.14.0 + Mathlib)
are an external source register. The actual AxiomaticBuild.lean was NOT
among the supplied files or verified repository sources, so its claimed
12-axiom canonicalWitness is not imported and not re-certified here.

The Gate is defined only for typed candidates. Survival is independently
required. Error components drop/add/strength are separately zero-tested.
The future scope F is a typed address and a candidate, not an observed
future event or a proof of a dynamical physical realization.

The exact physical C-infinity ADM SmoothCompletion remains a distinct
formalization: it needs a Real-valued, tensor-typed weak symplectic and
Fréchet functional calculus. 010t proves only a finite Rat-valued kernel.
-/

set_option autoImplicit false

namespace UniversalClosure010u

inductive GateOutcome where
  | can
  | fold2
  deriving DecidableEq, Repr

-- Gamma_J: jurisdiction and constraint before the Gate.
-- No term of `gate x` can be formed without a proof of `typed x`.
structure Jurisdiction (State : Type) where
  typed : State → Prop
  constraint : State → Prop
  gate : (x : State) → typed x → GateOutcome
  survival : State → Prop
  dropError : State → Nat
  addError : State → Nat
  strengthError : State → Nat

-- An admitted continuation contains its actual typing witness.
-- Gate and survival remain independent fields.
def Admitted {State : Type} (J : Jurisdiction State) (x : State) : Prop :=
  ∃ hx : J.typed x,
    J.constraint x ∧
    J.gate x hx = GateOutcome.can ∧
    J.survival x ∧
    J.dropError x = 0 ∧
    J.addError x = 0 ∧
    J.strengthError x = 0

-- A typed fold has no admitted continuation at that address.
def Folded {State : Type} (J : Jurisdiction State) (x : State) : Prop :=
  ∃ hx : J.typed x, J.gate x hx = GateOutcome.fold2

theorem admit_requires_owner {State : Type}
    (J : Jurisdiction State) (x : State) :
    Admitted J x → J.constraint x := by
  rintro ⟨_, hc, _, _, _, _, _⟩
  exact hc

theorem admit_requires_type {State : Type}
    (J : Jurisdiction State) (x : State) :
    Admitted J x → J.typed x := by
  rintro ⟨hx, _, _, _, _, _, _⟩
  exact hx

theorem admit_preserves_three_residuals {State : Type}
    (J : Jurisdiction State) (x : State) :
    Admitted J x →
      J.dropError x = 0 ∧ J.addError x = 0 ∧ J.strengthError x = 0 := by
  rintro ⟨_, _, _, _, hd, ha, hs⟩
  exact ⟨hd, ha, hs⟩

theorem admit_requires_survival {State : Type}
    (J : Jurisdiction State) (x : State) :
    Admitted J x → J.survival x := by
  rintro ⟨_, _, _, hs, _, _, _⟩
  exact hs

theorem gate_has_exactly_two_typed_outcomes (g : GateOutcome) :
    g = GateOutcome.can ∨ g = GateOutcome.fold2 := by
  cases g with
  | can => exact Or.inl rfl
  | fold2 => exact Or.inr rfl

theorem folded_refuses_admission {State : Type}
    (J : Jurisdiction State) (x : State) :
    Folded J x → ¬ Admitted J x := by
  rintro ⟨hfold, hf⟩ ⟨hadm, _, hcan, _, _, _, _⟩
  have hp : hfold = hadm := Subsingleton.elim _ _
  rw [hp, hcan] at hf
  cases hf

-- A future candidate may be typed while the constraint refuses it.
-- This supplies a negative control for a false universal admission claim.
def exampleJurisdiction : Jurisdiction Bool where
  typed := fun _ => True
  constraint := fun x => x = true
  gate := fun _ _ => GateOutcome.can
  survival := fun _ => True
  dropError := fun _ => 0
  addError := fun _ => 0
  strengthError := fun _ => 0

theorem future_is_not_automatically_admitted :
    exampleJurisdiction.typed false ∧ ¬ Admitted exampleJurisdiction false := by
  constructor
  · trivial
  · rintro ⟨_, hc, _, _, _, _, _⟩
    cases hc

-- H_n and F are different constructor addresses.
inductive HorizonSlot (Receipt State : Type) where
  | historical : Receipt → HorizonSlot Receipt State
  | future : Nat → State → HorizonSlot Receipt State

theorem horizon_future_is_distinct_from_history
    {Receipt State : Type} (n : Nat) (x : State) (r : Receipt) :
    HorizonSlot.future n x ≠ HorizonSlot.historical r := by
  intro h
  cases h

-- An issued receipt is append-only; `fold2` leaves the ledger fixed.
def stepHistory {Receipt : Type}
    (outcome : GateOutcome) (prior : List Receipt) (r : Receipt) : List Receipt :=
  match outcome with
  | .can => prior ++ [r]
  | .fold2 => prior

theorem can_retains_prior_history {Receipt : Type}
    (prior : List Receipt) (r : Receipt) :
    (stepHistory GateOutcome.can prior r).take prior.length = prior := by
  simp [stepHistory]

theorem can_adds_one_occurrence {Receipt : Type}
    (prior : List Receipt) (r : Receipt) :
    (stepHistory GateOutcome.can prior r).length = prior.length + 1 := by
  simp [stepHistory]

theorem fold_preserves_history {Receipt : Type}
    (prior : List Receipt) (r : Receipt) :
    stepHistory GateOutcome.fold2 prior r = prior := rfl

-- Scope reader: evidence and the recognized value are separately typed.
structure Reader (State Output : Type) where
  read : State → Output
  compatible : State → Output → Prop

def Enough {State Output : Type}
    (J : Jurisdiction State) (R : Reader State Output)
    (receiptOK : State → Prop) (x : State) : Prop :=
  Admitted J x ∧ receiptOK x ∧
    (∀ y, R.compatible x y ↔ y = R.read x)

theorem enough_selects_unique_receipt {State Output : Type}
    (J : Jurisdiction State) (R : Reader State Output)
    (receiptOK : State → Prop) (x : State)
    (he : Enough J R receiptOK x) (y : Output)
    (hy : R.compatible x y) : y = R.read x := by
  exact (he.2.2 y).mp hy

theorem enough_preserves_owner {State Output : Type}
    (J : Jurisdiction State) (R : Reader State Output)
    (receiptOK : State → Prop) (x : State)
    (he : Enough J R receiptOK x) : J.constraint x := by
  exact admit_requires_owner J x he.1

-- A coarse reader collision cannot reconstruct a more discriminating
-- Difference from the coarse value alone, without a supplement.
theorem collision_refuses_unsourced_reconstruction
    {State Output Difference : Type}
    (rho : State → Output) (delta : State → Difference)
    (x y : State)
    (hRead : rho x = rho y) (hDiff : delta x ≠ delta y) :
    ¬ ∃ decoder : Output → Difference,
        ∀ z : State, decoder (rho z) = delta z := by
  rintro ⟨decoder, hd⟩
  apply hDiff
  calc
    delta x = decoder (rho x) := (hd x).symm
    _ = decoder (rho y) := congrArg decoder hRead
    _ = delta y := hd y

-- Every `Enough` packet returns only its unique value and retains
-- both survival and the no-drop/no-add/no-inflation commitments.
theorem universal_scoped_closure
    {State Output Receipt : Type}
    (J : Jurisdiction State) (R : Reader State Output)
    (receiptOK : State → Prop) (x : State)
    (he : Enough J R receiptOK x)
    (prior : List Receipt) (r : Receipt) :
    J.typed x ∧
    J.constraint x ∧
    J.survival x ∧
    J.dropError x = 0 ∧
    J.addError x = 0 ∧
    J.strengthError x = 0 ∧
    (∀ y, R.compatible x y → y = R.read x) ∧
    (stepHistory GateOutcome.can prior r).take prior.length = prior := by
  have ha := he.1
  rcases ha with ⟨ht, hc, _, hs, hd, hnew, hinfl⟩
  refine ⟨ht, hc, hs, hd, hnew, hinfl, ?_, ?_⟩
  · intro y hy
    exact (he.2.2 y).mp hy
  · exact can_retains_prior_history prior r

-- A constructed finite witness shows the universal implication is inhabited.
-- It does not stand in for AxiomaticBuild.canonicalWitness (source absent).
def exampleReader : Reader Bool Bool where
  read := fun x => x
  compatible := fun x y => y = x

def exampleEvidence (x : Bool) : Prop := x = true

theorem finite_enough_witness :
    Enough exampleJurisdiction exampleReader exampleEvidence true := by
  refine ⟨?_, rfl, ?_⟩
  · exact ⟨True.intro, rfl, rfl, True.intro, rfl, rfl, rfl⟩
  · intro y
    exact Iff.rfl

-- The coarse value alone cannot reconstruct a hidden difference.
-- Here the supplement is explicitly sufficient in the finite model.
def coarseReader (_ : Bool) : Bool := false
def supplementReader (x : Bool) : Bool := x

theorem coarse_pair_collision :
    coarseReader true = coarseReader false ∧
    supplementReader true ≠ supplementReader false := by decide

theorem supplement_repairs_this_collision (x y : Bool) :
    (coarseReader x, supplementReader x) =
      (coarseReader y, supplementReader y) → x = y := by
  intro h
  exact congrArg Prod.snd h

-- These source witnesses keep the old branches intact without promoting
-- a finite rational computation into a C-infinity/quantum-field result.
theorem prime_source_nonzero :
    PrimeRationalSymplectic010t.canonicalPB
      PrimeRationalSymplectic010t.metricGradient0
      PrimeRationalSymplectic010t.momentumGradient0 = (1 : Rat) :=
  PrimeRationalSymplectic010t.rational_canonical_bracket_nonzero

theorem spectral_refusal_is_retained :
    ¬ (YMGapRefusal010r.FixedNonabelianGauss →
        YMGapRefusal010r.HasPositiveRationalGap
          YMGapRefusal010r.accumulatingExcitations) ∧
    ¬ (YMGapRefusal010r.FixedNonabelianGauss →
        ¬ YMGapRefusal010r.HasPositiveRationalGap
          YMGapRefusal010r.constantExcitations) := by
  exact ⟨YMGapRefusal010r.commutators_do_not_force_positive_gap,
    YMGapRefusal010r.commutators_do_not_force_gaplessness⟩

-- Source-anchored proof terminals: these checks ensure the previously
-- separate Fourier/canonical branches remain compiled in this closure.
#check FourierGradient010n.momentum_gradient_pairing
#check QuadraticTransport010m.finite_canonical_quadratic_closure
#check FourierConstraints010l.finite_fourier_semidirect
#check LinearTransport010f.PB_transport_transport

#print axioms admit_requires_owner
#print axioms admit_requires_type
#print axioms admit_preserves_three_residuals
#print axioms admit_requires_survival
#print axioms gate_has_exactly_two_typed_outcomes
#print axioms folded_refuses_admission
#print axioms future_is_not_automatically_admitted
#print axioms horizon_future_is_distinct_from_history
#print axioms can_retains_prior_history
#print axioms can_adds_one_occurrence
#print axioms fold_preserves_history
#print axioms enough_selects_unique_receipt
#print axioms enough_preserves_owner
#print axioms collision_refuses_unsourced_reconstruction
#print axioms universal_scoped_closure
#print axioms finite_enough_witness
#print axioms coarse_pair_collision
#print axioms supplement_repairs_this_collision
#print axioms prime_source_nonzero
#print axioms spectral_refusal_is_retained

end UniversalClosure010u
