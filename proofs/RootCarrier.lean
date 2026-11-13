/-!
# Root carrier: regularity at Pi_0, one finite witness set

Integer linear algebra only.  Core Lean 4, no Mathlib, kernel evaluation
(`decide +kernel`).  Matrices are lists of rows.

Carrier (published conventions):
  G = [[-2,1],[1,2]],  C = [[0,-1],[1,0]],
  eta = G (+) I_6  (8x8),   Chat = C (+) C (+) C (+) C  (8x8),
  Pi_0 = (o1, o2+o3, o4, o5)  (8x4, standard basis in block order).

What this file proves
  1. G^2 = 5 I.
  2. The induced form h = Pi_0^T eta Pi_0, its congruence witness
     T^T h T = diag(-2, 14, 1, 1) with T T' = 2 I (T invertible over Q),
     and det of the nondegenerate block, giving Lorentzian signature (3,1)
     by the sign pattern of the diagonal witness.
  3. The differential dS at Pi_0 of S(Pi) = (Pi^T eta Pi, Pi^T Chat Pi)
     (10 + 6 = 16 components) is onto: for each of the 16 coordinate
     directions e_k an explicit integer V_k gives dS(V_k) = 30 e_k.
  4. The nonzero X = 0_6 (+) C preserves eta and Chat and annihilates Pi_0.

Not proved here (stated in the paper, checked in Python only):
  dim k = 10, orbit rank 9 at Pi_0, the rank-nullity step from item 3 to a
  16-dimensional kernel, and the magnetic invariant.  No physical claim.
-/
set_option autoImplicit false

namespace RootCarrier

def col (A : List (List Int)) (j : Nat) : List Int := A.map (fun r => r.getD j 0)

def dot (u v : List Int) : Int :=
  (List.zipWith (fun (x y : Int) => x * y) u v).foldl (fun (s x : Int) => s + x) 0

def tr (A : List (List Int)) (n : Nat) : List (List Int) :=
  (List.range n).map (fun j => col A j)

def mmul (A B : List (List Int)) (n : Nat) : List (List Int) :=
  A.map (fun r => (List.range n).map (fun j => dot r (col B j)))

def madd (A B : List (List Int)) : List (List Int) :=
  List.zipWith (List.zipWith (fun (x y : Int) => x + y)) A B

def mscale (k : Int) (A : List (List Int)) : List (List Int) :=
  A.map (fun r => r.map (fun x => k * x))

def idMat (n : Nat) : List (List Int) :=
  (List.range n).map (fun i => (List.range n).map (fun j => if i = j then (1 : Int) else 0))

def zerosMat (r c : Nat) : List (List Int) :=
  List.replicate r (List.replicate c 0)

def blk (A B : List (List Int)) (na nb : Nat) : List (List Int) :=
  (A.map (fun r => r ++ List.replicate nb 0)) ++ (B.map (fun r => List.replicate na 0 ++ r))

def G2 : List (List Int) := [[-2, 1], [1, 2]]
def C2 : List (List Int) := [[0, -1], [1, 0]]

def eta : List (List Int) := blk G2 (idMat 6) 2 6
def Chat : List (List Int) := blk C2 (blk C2 (blk C2 C2 2 2) 2 4) 2 6

def Pi0 : List (List Int) :=
  [[1, 0, 0, 0], [0, 1, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0],
   [0, 0, 0, 1], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]

/-! ## 1. Root identity -/

theorem G_square : mmul G2 G2 2 = mscale 5 (idMat 2) := by decide +kernel

/-! ## 2. Induced form and Lorentzian congruence witness -/

def h : List (List Int) := mmul (tr Pi0 4) (mmul eta Pi0 4) 4

theorem h_value :
    h = [[-2, 1, 0, 0], [1, 3, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]] := by decide +kernel

def det2 (a b c d : Int) : Int := a * d - b * c

theorem h_block_det : det2 (-2) 1 1 3 = -7 := by decide +kernel

def T : List (List Int) :=
  [[1, 1, 0, 0], [0, 2, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]]
def Tadj : List (List Int) :=
  [[2, -1, 0, 0], [0, 1, 0, 0], [0, 0, 2, 0], [0, 0, 0, 2]]

-- T has an inverse over Q: T * Tadj = 2 I.
theorem T_invertible : mmul T Tadj 4 = mscale 2 (idMat 4) := by decide +kernel

-- Congruent to diag(-2, 14, 1, 1): one negative direction, three positive.
theorem h_congruence :
    mmul (tr T 4) (mmul h T 4) 4
      = [[-2, 0, 0, 0], [0, 14, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]] := by decide +kernel

/-! ## 3. dS at Pi_0 is onto Z^16 (scaled by 30) -/

def entriesUpper (g : List (List Int)) : List Int :=
  (List.range 4).flatMap (fun i => (List.range 4).filterMap (fun j =>
    if i ≤ j then some ((g.getD i []).getD j 0) else none))

def entriesStrict (g : List (List Int)) : List Int :=
  (List.range 4).flatMap (fun i => (List.range 4).filterMap (fun j =>
    if i < j then some ((g.getD i []).getD j 0) else none))

-- Differential of S at Pi in direction V: 10 symmetric + 6 antisymmetric components.
def dS (Pi V : List (List Int)) : List Int :=
  let g := madd (mmul (tr V 4) (mmul eta Pi 4) 4) (mmul (tr Pi 4) (mmul eta V 4) 4)
  let f := madd (mmul (tr V 4) (mmul Chat Pi 4) 4) (mmul (tr Pi 4) (mmul Chat V 4) 4)
  entriesUpper g ++ entriesStrict f

def unitScaled (k : Nat) : List Int :=
  (List.range 16).map (fun i => if i = k then (30 : Int) else 0)

def preimages : List (List (List Int)) := [
    [[-5, 2, -2, 0], [5, 0, 1, 0], [-1, -2, 0, 0], [-5, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
    [[5, -2, 2, 0], [10, 0, -1, 0], [1, 2, 0, 0], [5, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
    [[5, 10, -10, 0], [10, 0, 5, 0], [-5, -10, 0, 0], [5, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
    [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [30, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
    [[5, 13, 2, 0], [10, 0, -1, 0], [1, 2, 0, 0], [5, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
    [[0, -6, 6, 0], [0, 0, 12, 0], [-12, 6, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
    [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 30, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
    [[5, 13, 2, 0], [10, 0, -1, 0], [1, -13, 0, 0], [5, 0, 15, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
    [[0, 0, 0, 30], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 30], [60, -30, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
    [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 15], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
    [[-5, -10, 10, 0], [-10, 0, -5, 0], [5, 10, 0, 0], [25, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
    [[5, -2, 2, 0], [10, 0, -1, 0], [-29, 2, 0, 0], [5, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
    [[0, 0, 0, 0], [0, 0, 0, -30], [0, 0, 0, 0], [0, 0, 0, 0], [30, 60, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
    [[10, 26, 4, 0], [20, 0, -2, 0], [2, -26, 0, 0], [10, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
    [[0, 0, 0, 30], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [60, -30, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
    [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 30], [0, 0, 0, 0], [0, -30, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]]

theorem dS_onto_certificate :
    preimages.map (dS Pi0) = (List.range 16).map unitScaled := by decide +kernel

/-! ## 4. The stabilizer element that fixes Pi_0 -/

def Xw : List (List Int) := blk (zerosMat 6 6) C2 6 2

theorem Xw_preserves_eta :
    madd (mmul (tr Xw 8) eta 8) (mmul eta Xw 8) = zerosMat 8 8 := by decide +kernel

theorem Xw_preserves_Chat :
    madd (mmul (tr Xw 8) Chat 8) (mmul Chat Xw 8) = zerosMat 8 8 := by decide +kernel

theorem Xw_kills_Pi0 : mmul Xw Pi0 4 = zerosMat 8 4 := by decide +kernel

theorem Xw_nonzero : Xw ≠ zerosMat 8 8 := by decide +kernel

end RootCarrier

#print axioms RootCarrier.dS_onto_certificate
#print axioms RootCarrier.h_congruence
#print axioms RootCarrier.Xw_kills_Pi0
