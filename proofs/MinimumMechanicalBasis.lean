import proofs.RootCarrier
import proofs.RootProjectiveAdapters_v2
import proofs.MultiplierElimination
import proofs.StabilizerDim
import proofs.MagneticValueAtPi0

/-!
# Minimum mechanical basis — one exact Lean 4 certificate

The owning references are:
  Minimum Mechanics, readable edition 1.0, proofs 1-21;
  Minimum Root Chain v1.8, especially E0.4, E1.9, E13, E14, N, P;
  Infinity One Zero Lift, projective and axial adapters;
  Suture Field, SF.0-SF.10 and SF.29;
  Suture Field Dynamics, SD.3-SD.5 and SD.16-SD.20.

The certificate joins exact finite identities.  The original Lean witnesses
are imported rather than transcribed or silently reconstructed.

Proved in this file:
  * the one-step read/erasure obstruction (for any types and maps);
  * counted phase return with non-returning occurrence;
  * the exact normalized axial square and mirror reversal over Q(sqrt 5);
  * the full 8x8 mirror preservation of the symmetric form, and reversal
    of the antisymmetric form (the Suture Field algebraic interface);
  * the complete 7x4 scan of K8 at the level of finite edge addresses;
  * one named conjunction of these and the existing root/projective/
    regular-suture and multiplier certificates.

The last theorem is not a proof of the coupled Einstein-Maxwell field
Euler equations, global Hamiltonian equivalence, or empirical realization.
Those require the separately stated dynamical hypotheses and reductions.

Lean 4.33.0; no Mathlib.  This file belongs in the existing repository's
`proofs/` directory so its imports resolve.  All arithmetic is exact.
-/

set_option autoImplicit false

namespace MinimumMechanicalBasis

open RootProjectiveAdapters

/-! Part zero. Read precedes the relation it defines. -/

theorem loss_obstruction
    {X Y Z : Type} (read : X → Y) (required : X → Z)
    (x y : X) (sameRead : read x = read y)
    (differentUse : required x ≠ required y) :
    ¬ ∃ decoder : Y → Z, ∀ z : X, decoder (read z) = required z := by
  intro witness
  cases witness with
  | intro decoder reconstruct =>
      apply differentUse
      calc
        required x = decoder (read x) := (reconstruct x).symm
        _ = decoder (read y) := congrArg decoder sameRead
        _ = required y := reconstruct y

/-! Part one. Return of phase while the occurrence advances. -/

theorem four_phase_carry (n : Nat) :
    (n + 4) % 4 = n % 4 ∧
    (n + 4) / 4 = n / 4 + 1 ∧
    n + 4 ≠ n := by
  omega

/-! Part two begins with the two exact reflections of P.1. -/

def S : QMat2 :=
  qMatScale qInvSqrt5 (qLiftIntMat ⟨1, 2, 2, -1⟩)

theorem frame_closure :
    qMatMul qH S = qLiftIntMat ⟨0, -1, 1, 0⟩ ∧
    qMatMul S qH = qLiftIntMat ⟨0, 1, -1, 0⟩ ∧
    qMatMul S S = qI ∧
    qMatMul qH qH = qI := by
  decide +kernel

/-! Part two. The real root and the axial carriage, in Q(sqrt 5).
    These are the same scalar and matrix types as the committed adapter. -/

def B : QMat2 :=
  qLiftIntMat ⟨2, 1, 1, 1⟩

def BInv : QMat2 :=
  qLiftIntMat ⟨1, -1, -1, 2⟩

def C : QMat2 :=
  qLiftIntMat ⟨0, -1, 1, 0⟩

def CInv : QMat2 :=
  qLiftIntMat ⟨0, 1, -1, 0⟩

-- L_ax = (Q + 2 I) / sqrt(5) = [[3,1],[1,2]]/sqrt(5).
def Lax : QMat2 :=
  qMatScale qInvSqrt5 (qLiftIntMat ⟨3, 1, 1, 2⟩)

def LaxInv : QMat2 :=
  qMatScale qInvSqrt5 (qLiftIntMat ⟨2, -1, -1, 3⟩)

theorem axial_square : qMatMul Lax Lax = B := by decide +kernel

theorem axial_inverse : qMatMul Lax LaxInv = qI := by decide +kernel

theorem axial_metric :
    qMatMul (qMatTranspose Lax) (qMatMul qG Lax) = qG := by
  decide +kernel

theorem axial_mirror :
    qMatMul (qMatMul qH Lax) qH = LaxInv := by decide +kernel

theorem even_carriage_mirror :
    qMatMul (qMatMul qH B) qH = BInv := by decide +kernel

theorem quarter_turn_mirror :
    qMatMul (qMatMul qH C) qH = CInv := by decide +kernel

/-! Part three. SF.7-SF.10: one metric and one flux form on the same
    eight-dimensional carrier.  Exact calculations are performed in
    Q(sqrt 5).  The source's Hhat = H (+) D (+) D (+) D. -/

abbrev M := List (List Qsqrt5)

def entry2 (a : QMat2) : M := [[a.a, a.b], [a.c, a.d]]

def col (a : M) (j : Nat) : List Qsqrt5 :=
  a.map (fun r => r.getD j qZero)

def dot (a b : List Qsqrt5) : Qsqrt5 :=
  (List.zipWith qMul a b).foldl qAdd qZero

def tr (a : M) (n : Nat) : M :=
  (List.range n).map (fun j => col a j)

def mul (a b : M) (n : Nat) : M :=
  a.map (fun r => (List.range n).map (fun j => dot r (col b j)))

def scale (k : Qsqrt5) (a : M) : M :=
  a.map (fun r => r.map (fun x => qMul k x))

def idMat (n : Nat) : M :=
  (List.range n).map (fun i =>
    (List.range n).map (fun j => if i = j then qOne else qZero))

def block (a b : M) (na nb : Nat) : M :=
  (a.map (fun r => r ++ List.replicate nb qZero)) ++
  (b.map (fun r => List.replicate na qZero ++ r))

def D : QMat2 :=
  ⟨qOne, qZero, qZero, qOfInt (-1)⟩

def etaHat : M :=
  block (entry2 qG) (idMat 6) 2 6

def cHat : M :=
  block (entry2 C)
    (block (entry2 C) (block (entry2 C) (entry2 C) 2 2) 2 4) 2 6

def mirrorHat : M :=
  block (entry2 qH)
    (block (entry2 D) (block (entry2 D) (entry2 D) 2 2) 2 4) 2 6

theorem metric_mirror :
    mul (tr mirrorHat 8) (mul etaHat mirrorHat 8) 8 = etaHat := by
  decide +kernel

theorem flux_mirror :
    mul (tr mirrorHat 8) (mul cHat mirrorHat 8) 8 =
      scale (qOfInt (-1)) cHat := by
  decide +kernel

/-! Part four. LM-011: the selected Z7 construction scans K8 once. -/

def pair (x y : Nat) : Nat × Nat :=
  (min x y, max x y)

def seam (a j : Nat) : Nat × Nat :=
  if j = 0 then pair 7 a
  else pair ((a + j) % 7) ((a + 7 - j) % 7)

def scan : List (Nat × Nat) :=
  (List.range 7).flatMap (fun a =>
    (List.range 4).map (fun j => seam a j))

def allEdges : List (Nat × Nat) :=
  (List.range 8).flatMap (fun x =>
    (List.range 8).filterMap (fun y =>
      if x < y then some (x, y) else none))

theorem complete_scan :
    scan.length = 28 ∧
    scan.Nodup ∧
    allEdges.length = 28 ∧
    (allEdges.all (fun edge => scan.contains edge)) = true := by
  decide +kernel

/-! One theorem, with a source-faithful statement for each component.
    Imported certificates establish a regular *pointwise witness* and
    the stated finite multiplier pairings.  No global field theorem is
    smuggled into their conjunction. -/

structure MinimumCertificate : Prop where
  loss : ∀ {X Y Z : Type} (read : X → Y) (required : X → Z)
      (x y : X), read x = read y → required x ≠ required y →
      ¬ ∃ decoder : Y → Z, ∀ z : X, decoder (read z) = required z
  root : RootCarrier.mmul RootCarrier.G2 RootCarrier.G2 2 =
         RootCarrier.mscale 5 (RootCarrier.idMat 2)
  realBridge :
    qMatMul (qMatMul P qH) PInv = qM
  complexBridge :
    ProjectiveReturn.gMul (ProjectiveReturn.gMul Z gC) ZInv = ProjectiveReturn.iM
  frame :
    qMatMul qH S = qLiftIntMat ⟨0, -1, 1, 0⟩ ∧
    qMatMul S qH = qLiftIntMat ⟨0, 1, -1, 0⟩ ∧
    qMatMul S S = qI ∧
    qMatMul qH qH = qI
  axial : qMatMul Lax Lax = B
  axialMetric : qMatMul (qMatTranspose Lax) (qMatMul qG Lax) = qG
  axialMirror : qMatMul (qMatMul qH Lax) qH = LaxInv
  evenMirror : qMatMul (qMatMul qH B) qH = BInv
  quarterMirror : qMatMul (qMatMul qH C) qH = CInv
  metric : mul (tr mirrorHat 8) (mul etaHat mirrorHat 8) 8 = etaHat
  flux : mul (tr mirrorHat 8) (mul cHat mirrorHat 8) 8 =
           scale (qOfInt (-1)) cHat
  phase : ∀ n : Nat,
    (n + 4) % 4 = n % 4 ∧
    (n + 4) / 4 = n / 4 + 1 ∧
    n + 4 ≠ n
  matching : scan.length = 28 ∧ scan.Nodup ∧ allEdges.length = 28 ∧
    (allEdges.all (fun edge => scan.contains edge)) = true
  lorentzianWitness :
    RootCarrier.mmul (RootCarrier.tr RootCarrier.T 4)
      (RootCarrier.mmul RootCarrier.h RootCarrier.T 4) 4 =
      [[-2, 0, 0, 0], [0, 14, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]]
  ontoWitness :
    RootCarrier.preimages.map (RootCarrier.dS RootCarrier.Pi0) =
      (List.range 16).map RootCarrier.unitScaled
  stabilizerBasis :
    StabilizerDim.basis.map StabilizerDim.constraint =
      List.replicate 10 (List.replicate 128 0)
  stabilizerIndependent :
    StabilizerDim.mmul StabilizerDim.Wm StabilizerDim.Nmat 10 =
      StabilizerDim.mscale 30 (StabilizerDim.idMat 10)
  stabilizerUpperBound :
    StabilizerDim.madd
      (StabilizerDim.mmul StabilizerDim.Nmat StabilizerDim.Wm 64)
      (StabilizerDim.sparseMmul StabilizerDim.Am StabilizerDim.Emat 64) =
      StabilizerDim.mscale 30 (StabilizerDim.idMat 64)
  orbitFibre :
    MultiplierElimination.basis.map
      (fun X => MultiplierElimination.dS MultiplierElimination.Pi0
        (MultiplierElimination.mmul X MultiplierElimination.Pi0 4)) =
      List.replicate 10 (List.replicate 16 0)
  multiplierRightInverse :
    MultiplierElimination.mmul MultiplierElimination.DSmat
      (MultiplierElimination.tr MultiplierElimination.Pmat 32) 16 =
      MultiplierElimination.mscale 30 (MultiplierElimination.idMat 16)
  multiplierLeftInverse :
    MultiplierElimination.mmul MultiplierElimination.Pmat
      (MultiplierElimination.tr MultiplierElimination.DSmat 32) 16 =
      MultiplierElimination.mscale 30 (MultiplierElimination.idMat 16)
  magneticAtWitness : (14 : Int) < 2 * 49

-- One kernel-checkable closure of the minimum mechanical basis.
theorem minimum_mechanical_basis : MinimumCertificate :=
  { loss := by
      intro X Y Z read required x y sameRead differentUse
      exact loss_obstruction read required x y sameRead differentUse
    root := RootCarrier.G_square
    realBridge := RootProjectiveAdapters.real_adapter_conjugacy
    complexBridge := RootProjectiveAdapters.complex_adapter_conjugacy
    frame := frame_closure
    axial := axial_square
    axialMetric := axial_metric
    axialMirror := axial_mirror
    evenMirror := even_carriage_mirror
    quarterMirror := quarter_turn_mirror
    metric := metric_mirror
    flux := flux_mirror
    phase := four_phase_carry
    matching := complete_scan
    lorentzianWitness := RootCarrier.h_congruence
    ontoWitness := RootCarrier.dS_onto_certificate
    stabilizerBasis := StabilizerDim.basis_in_k
    stabilizerIndependent := StabilizerDim.independent
    stabilizerUpperBound := StabilizerDim.upper_bound
    orbitFibre := MultiplierElimination.orbit_directions_in_fibre
    multiplierRightInverse := MultiplierElimination.DS_times_Pt
    multiplierLeftInverse := MultiplierElimination.P_times_DSt
    magneticAtWitness := MagneticInvariant.regular_domain }

end MinimumMechanicalBasis

#print axioms MinimumMechanicalBasis.minimum_mechanical_basis
