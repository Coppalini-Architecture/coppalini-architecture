import proofs.MultiplierElimination
import proofs.RootCarrier

set_option autoImplicit false

/-!
Suture Euler Reduction — exact local variational and canonical certificates
Owning equations: Suture Field Dynamics, SD.3–SD.5, SD.12–SD.20e.
A surjective suture differential forces the coframe multiplier to vanish.
The remaining field variation then equals the base-field variation.
The canonical 64-coordinate auxiliary bracket has an explicit inverse.
The imported exact Pi0 certificate supplies the scaled right inverse.
-/

namespace SutureEulerReduction

-- Read: the suture map into metric-and-flux coordinates.
def Read (P X : Type) := P → X

-- Tangent: linearized coframe variations mapped to base-field variations.
def Tangent (P X : Type) := P → X

-- Euler: the first variation of the base-field action.
def Euler (X : Type) := X → Int

-- Stationary: zero first variation along every supplied direction.
def Stationary {X : Type} (d : Euler X) : Prop :=
  ∀ v : X, d v = 0

-- SutureStationary: coframe and field variation of m·(X-S(Pi)).
def SutureStationary {P X : Type} (DS : Tangent P X)
    (dBase m : Euler X) : Prop :=
  (∀ v : P, m (DS v) = 0) ∧
  (∀ v : X, dBase v + m v = 0)

-- The coframe stationarity equation annihilates the multiplier.
theorem multiplier_zero {P X : Type} (DS : Tangent P X)
    (m : Euler X) (regular : Function.Surjective DS)
    (coframeEuler : ∀ v : P, m (DS v) = 0) :
    Stationary m := by
  intro x
  obtain ⟨v, hv⟩ := regular x
  rw [← hv]
  exact coframeEuler v

-- SD.18: the constrained and base Euler equations coincide on a regular branch.
theorem regular_euler_equivalence {P X : Type}
    (DS : Tangent P X) (dBase m : Euler X)
    (regular : Function.Surjective DS) :
    SutureStationary DS dBase m ↔
      Stationary dBase ∧ Stationary m := by
  constructor
  · intro h
    have hm : Stationary m := multiplier_zero DS m regular h.1
    constructor
    · intro v
      have hv := h.2 v
      simpa [hm v] using hv
    · exact hm
  · intro h
    constructor
    · intro v
      exact h.2 (DS v)
    · intro v
      simp [h.1 v, h.2 v]

-- The constraint equation from multiplier variation is retained.
def ConstrainedEuler {P X : Type}
    (S : Read P X) (DS : Tangent P X)
    (dBase m : Euler X) (pi : P) (x : X) : Prop :=
  S pi = x ∧ SutureStationary DS dBase m

theorem regular_constrained_euler {P X : Type}
    (S : Read P X) (DS : Tangent P X) (dBase m : Euler X)
    (pi : P) (x : X) (regular : Function.Surjective DS) :
    ConstrainedEuler S DS dBase m pi x ↔
      S pi = x ∧ Stationary dBase ∧ Stationary m := by
  constructor
  · intro h
    exact ⟨h.1, (regular_euler_equivalence DS dBase m regular).mp h.2⟩
  · intro h
    exact ⟨h.1, (regular_euler_equivalence DS dBase m regular).mpr h.2⟩

-- Aux: sixteen components in each of four canonical constraint slots.
structure Aux where
  pq : Fin 16 → Int
  c  : Fin 16 → Int
  pm : Fin 16 → Int
  m  : Fin 16 → Int

def zero : Aux := ⟨fun _ => 0, fun _ => 0, fun _ => 0, fun _ => 0⟩

def negative (a : Aux) : Aux :=
  ⟨fun i => -a.pq i, fun i => -a.c i,
   fun i => -a.pm i, fun i => -a.m i⟩

-- SD.20e: canonical 64×64 auxiliary bracket as a linear operator.
def bracket (a : Aux) : Aux :=
  ⟨fun i => -a.c i, fun i => a.pq i,
   fun i => -a.m i, fun i => a.pm i⟩

theorem bracket_square (a : Aux) :
    bracket (bracket a) = negative a := by
  cases a with
  | mk pq c pm m =>
    simp [bracket, negative]

theorem bracket_inverse_left (a : Aux) :
    bracket (negative (bracket a)) = a := by
  cases a with
  | mk pq c pm m =>
    simp [bracket, negative]

theorem bracket_inverse_right (a : Aux) :
    negative (bracket (bracket a)) = a := by
  cases a with
  | mk pq c pm m =>
    simp [bracket, negative]

theorem bracket_kernel (a : Aux) (h : bracket a = zero) :
    a = zero := by
  have hh : a = negative (bracket zero) := by
    simpa only [bracket_inverse_right] using
      congrArg (fun z => negative (bracket z)) h
  have hz : negative (bracket zero) = zero := by
    simp [zero, negative, bracket]
  exact hh.trans hz

theorem bracket_surjective (b : Aux) :
    ∃ a : Aux, bracket a = b := by
  exact ⟨negative (bracket b), bracket_inverse_left b⟩

-- Pointwise Pi0: DS·Pᵀ = 30 I16, an exact nonzero rank certificate.
theorem regular_suture_certificate :
    MultiplierElimination.mmul MultiplierElimination.DSmat
        (MultiplierElimination.tr MultiplierElimination.Pmat 32) 16 =
      MultiplierElimination.mscale 30 (MultiplierElimination.idMat 16) :=
  MultiplierElimination.DS_times_Pt

theorem regular_dual_certificate :
    MultiplierElimination.mmul MultiplierElimination.Pmat
        (MultiplierElimination.tr MultiplierElimination.DSmat 32) 16 =
      MultiplierElimination.mscale 30 (MultiplierElimination.idMat 16) :=
  MultiplierElimination.P_times_DSt

-- One proof target combines Euler reduction, Hamiltonian pairing, and Pi0 rank.
structure EulerCertificate : Prop where
  variation : ∀ {P X : Type} (DS : Tangent P X)
      (dBase m : Euler X), Function.Surjective DS →
      (SutureStationary DS dBase m ↔
        Stationary dBase ∧ Stationary m)
  bracket_left : ∀ a : Aux, bracket (negative (bracket a)) = a
  bracket_right : ∀ a : Aux, negative (bracket (bracket a)) = a
  regular : MultiplierElimination.mmul MultiplierElimination.DSmat
      (MultiplierElimination.tr MultiplierElimination.Pmat 32) 16 =
      MultiplierElimination.mscale 30 (MultiplierElimination.idMat 16)

theorem suture_euler_reduction : EulerCertificate :=
  { variation := by
      intro P X DS dBase m regular
      exact regular_euler_equivalence DS dBase m regular
    bracket_left := bracket_inverse_left
    bracket_right := bracket_inverse_right
    regular := regular_suture_certificate }

end SutureEulerReduction

#print axioms SutureEulerReduction.suture_euler_reduction
