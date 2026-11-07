/-!
# MoneyRoot Mirror Algebra v0.1

Lean 4.33 source for a bounded reader/fiber/decision layer and the exact
integer mirror root. The source makes no economic, physical, legal, or
empirical claim; it awaits an independent Lean elaboration receipt.
-/

set_option autoImplicit false

universe uX uC uA uU

namespace MoneyRootMirrorAlgebra

def EqKernel {X : Type uX} {C : Type uC} (R : X → C) (x y : X) : Prop :=
  R x = R y

def FiberRefines {X : Type uX} {C : Type uC} {A : Type uA}
    (R : X → C) (D : X → A) : Prop :=
  ∀ ⦃x y : X⦄, R x = R y → D x = D y

def DecisionCollision {X : Type uX} {C : Type uC} {A : Type uA}
    (R : X → C) (D : X → A) : Prop :=
  ∃ x y : X, R x = R y ∧ D x ≠ D y

def ReadQuot {X : Type uX} {C : Type uC} (R : X → C) : Type uX :=
  Quot (fun x y : X => R x = R y)

def qread {X : Type uX} {C : Type uC} (R : X → C) (x : X) : ReadQuot R :=
  Quot.mk (fun a b : X => R a = R b) x

def FactorsThroughRead {X : Type uX} {C : Type uC} {A : Type uA}
    (R : X → C) (D : X → A) : Prop :=
  ∃ K : ReadQuot R → A, ∀ x : X, D x = K (qread R x)

theorem factorization_iff_fiber_refinement
    {X : Type uX} {C : Type uC} {A : Type uA}
    (R : X → C) (D : X → A) :
    FactorsThroughRead R D ↔ FiberRefines R D := by
  constructor
  · intro hFactors
    rcases hFactors with ⟨K, hK⟩
    intro x y hRead
    calc
      D x = K (qread R x) := hK x
      _ = K (qread R y) := congrArg K (Quot.sound hRead)
      _ = D y := (hK y).symm
  · intro hFiber
    let K : ReadQuot R → A := Quot.lift D (by
      intro x y hRead
      exact hFiber hRead)
    refine ⟨K, ?_⟩
    intro x
    rfl

theorem collision_refutes_factorization
    {X : Type uX} {C : Type uC} {A : Type uA}
    {R : X → C} {D : X → A}
    (hCollision : DecisionCollision R D) : ¬ FactorsThroughRead R D := by
  intro hFactors
  have hFiber : FiberRefines R D :=
    (factorization_iff_fiber_refinement R D).mp hFactors
  rcases hCollision with ⟨x, y, hRead, hDifferent⟩
  exact hDifferent (hFiber hRead)

def InducedAction {X : Type uX} {C : Type uC} {U : Type uU}
    (R : X → C) (κ : C → U) : X → U := fun x => κ (R x)

def ClosedLoop {X : Type uX} {C : Type uC} {U : Type uU}
    (T : X → U → X) (R : X → C) (κ : C → U) : X → X :=
  fun x => T x (κ (R x))

theorem same_read_same_induced_action
    {X : Type uX} {C : Type uC} {U : Type uU}
    {R : X → C} {κ : C → U} {x y : X}
    (hRead : R x = R y) :
    InducedAction R κ x = InducedAction R κ y := by
  exact congrArg κ hRead

theorem closed_loop_unfold
    {X : Type uX} {C : Type uC} {U : Type uU}
    (T : X → U → X) (R : X → C) (κ : C → U) (x : X) :
    ClosedLoop T R κ x = T x (κ (R x)) := by rfl

namespace SettlementWitness

structure State where
  grossIn : Int
  grossOut : Int
  deriving DecidableEq

def net (s : State) : Int := s.grossIn - s.grossOut
def grossTotal (s : State) : Int := s.grossIn + s.grossOut
def s₁ : State := ⟨1, 1⟩
def s₂ : State := ⟨2, 2⟩

theorem collision : DecisionCollision net grossTotal := by
  refine ⟨s₁, s₂, ?_, ?_⟩ <;> decide

theorem net_not_sufficient_for_gross_exposure :
    ¬ FactorsThroughRead net grossTotal := by
  exact collision_refutes_factorization collision

end SettlementWitness

structure Mat2 where
  a : Int
  b : Int
  c : Int
  d : Int
  deriving DecidableEq

def add (x y : Mat2) : Mat2 := ⟨x.a + y.a, x.b + y.b, x.c + y.c, x.d + y.d⟩
def neg (x : Mat2) : Mat2 := ⟨-x.a, -x.b, -x.c, -x.d⟩
def scale (k : Int) (x : Mat2) : Mat2 := ⟨k * x.a, k * x.b, k * x.c, k * x.d⟩
def mul (x y : Mat2) : Mat2 :=
  ⟨x.a * y.a + x.b * y.c, x.a * y.b + x.b * y.d,
   x.c * y.a + x.d * y.c, x.c * y.b + x.d * y.d⟩
def transpose (x : Mat2) : Mat2 := ⟨x.a, x.c, x.b, x.d⟩

def I : Mat2 := ⟨1, 0, 0, 1⟩
def Q : Mat2 := ⟨1, 1, 1, 0⟩
def Omega : Mat2 := ⟨0, 1, -1, 0⟩
def phaseI : Mat2 := neg Omega
def G : Mat2 := add (mul Q Omega) (neg (mul Omega Q))
def Sraw : Mat2 := add (scale 2 Q) (neg I)
def LPhiRaw : Mat2 := add Q (scale 2 I)
def D2 : Mat2 := scale 2 I

theorem q_square : mul Q Q = add Q I := by decide
theorem omega_square : mul Omega Omega = neg I := by decide
theorem phase_square : mul phaseI phaseI = neg I := by decide
theorem g_square : mul G G = scale 5 I := by decide
theorem q_metric_flip : mul (mul (transpose Q) G) Q = neg G := by decide
theorem sraw_square : mul Sraw Sraw = scale 5 I := by decide
theorem lphi_square : mul LPhiRaw LPhiRaw = scale 5 (mul Q Q) := by decide
theorem phase_mirror_clear : mul (mul G phaseI) G = scale (-5) phaseI := by decide
theorem scalar_two_mirror_clear : mul (mul G D2) G = scale 5 D2 := by decide
theorem phase_not_scalar : mul Q phaseI ≠ mul phaseI Q := by decide
theorem q_phase_commutator :
    add (mul Q phaseI) (neg (mul phaseI Q)) = neg G := by decide

end MoneyRootMirrorAlgebra
