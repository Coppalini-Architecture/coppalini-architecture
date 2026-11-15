import proofs.MinimumMechanicalBasis

set_option autoImplicit false

namespace MinimumMechanicalSpine

open RootProjectiveAdapters
open MinimumMechanicalBasis

/- Part zero: one name, one type. -/

-- Read: a declared map from states to observations.
def Read (X Y : Type) := X → Y

-- Same: equality at the declared Read.
def Same {X Y : Type} (ρ : Read X Y) (x y : X) : Prop :=
  ρ x = ρ y

-- Can: entry and preservation must both hold.
def Can {X : Type} (entry : X → Prop) (keep : X → X → Prop)
    (T : X → X) (x : X) : Prop :=
  entry x ∧ keep x (T x)

-- Return: Same after the declared transport.
def Return {X Y : Type} (ρ : Read X Y) (T : X → X) (x : X) : Prop :=
  Same ρ (T x) x

/- Part one: classical logic. -/

theorem same_equivalence {X Y : Type} (ρ : Read X Y) :
    Equivalence (Same ρ) := by
  constructor
  · intro x
    rfl
  · intro x y h
    exact h.symm
  · intro x y z hxy hyz
    exact hxy.trans hyz

theorem can_requires_keep {X : Type} (entry : X → Prop)
    (keep : X → X → Prop) (T : X → X) (x : X)
    (h : Can entry keep T x) : keep x (T x) := h.2

theorem no_decoder {X Y Z : Type} (ρ : Read X Y) (needed : X → Z)
    (x y : X) (h : Same ρ x y) (difference : needed x ≠ needed y) :
    ¬ ∃ decode : Y → Z, ∀ z : X, decode (ρ z) = needed z :=
  MinimumMechanicalBasis.loss_obstruction ρ needed x y h difference

/- Part two: the certified minimum mechanics, in dependency order. -/

structure Spine : Prop where
  admission : ∀ {X : Type} (entry : X → Prop) (keep : X → X → Prop)
    (T : X → X) (x : X), Can entry keep T x → keep x (T x)
  erasure : ∀ {X Y Z : Type} (ρ : Read X Y) (needed : X → Z)
    (x y : X), Same ρ x y → needed x ≠ needed y →
      ¬ ∃ decode : Y → Z, ∀ z : X, decode (ρ z) = needed z
  phase : ∀ n : Nat,
    (n + 4) % 4 = n % 4 ∧
    (n + 4) / 4 = n / 4 + 1 ∧
    n + 4 ≠ n
  root : RootCarrier.mmul RootCarrier.G2 RootCarrier.G2 2 =
    RootCarrier.mscale 5 (RootCarrier.idMat 2)
  frame : qMatMul qH S = qLiftIntMat ⟨0, -1, 1, 0⟩ ∧
    qMatMul S qH = qLiftIntMat ⟨0, 1, -1, 0⟩ ∧
    qMatMul S S = qI ∧ qMatMul qH qH = qI
  axial : qMatMul Lax Lax = B ∧
    qMatMul (qMatMul qH B) qH = BInv
  mirror : qMatMul (tr mirrorHat 8) (mul etaHat mirrorHat 8) 8 = etaHat ∧
    mul (tr mirrorHat 8) (mul cHat mirrorHat 8) 8 =
      scale (qOfInt (-1)) cHat
  regular : RootCarrier.preimages.map (RootCarrier.dS RootCarrier.Pi0) =
    (List.range 16).map RootCarrier.unitScaled
  scan : MinimumMechanicalBasis.scan.length = 28 ∧
    MinimumMechanicalBasis.scan.Nodup ∧
    MinimumMechanicalBasis.allEdges.length = 28 ∧
    (MinimumMechanicalBasis.allEdges.all
      (fun edge => MinimumMechanicalBasis.scan.contains edge)) = true

-- One certified return; every component has its own witness.
theorem minimum_mechanics : Spine :=
  { admission := by
      intro X entry keep T x h
      exact can_requires_keep entry keep T x h
    erasure := by
      intro X Y Z ρ needed x y h difference
      exact no_decoder ρ needed x y h difference
    phase := MinimumMechanicalBasis.four_phase_carry
    root := RootCarrier.G_square
    frame := MinimumMechanicalBasis.frame_closure
    axial := ⟨MinimumMechanicalBasis.axial_square,
              MinimumMechanicalBasis.even_carriage_mirror⟩
    mirror := ⟨MinimumMechanicalBasis.metric_mirror,
               MinimumMechanicalBasis.flux_mirror⟩
    regular := RootCarrier.dS_onto_certificate
    scan := MinimumMechanicalBasis.complete_scan }

end MinimumMechanicalSpine

#print axioms MinimumMechanicalSpine.minimum_mechanics
