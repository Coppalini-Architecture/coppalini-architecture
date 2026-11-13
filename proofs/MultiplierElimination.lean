/-!
# Pointwise multiplier elimination at Pi_0

Integer linear algebra only.  Core Lean 4, no Mathlib, `decide +kernel`.

Setting.  S(Pi) = (Pi^T eta Pi, Pi^T Chat Pi) takes values in a 16-dimensional
space (10 symmetric + 6 antisymmetric components).  The auxiliary term of the
dynamics is  m . (X - S(Pi)),  with X = (g, F) and multiplier m in R^16.
Its pointwise equations are
  vary m:   X = S(Pi)
  vary Pi:  (dS_Pi)^T m = 0
  vary X:   (the supplied Lagrangian's equation, with + m)
At a regular point dS_Pi is onto, so (dS_Pi)^T is injective and m = 0; the fibre
directions (coordinates xi) enter S not at all.

Proved here, at Pi_0
  1. dS * P^T = 30 I_16  and  P * dS^T = 30 I_16, where dS is the 16 x 32 matrix of
     dS at Pi_0 (computed from the definition on the 32 unit directions) and P is
     the 16 x 32 matrix whose rows are explicit integer preimages.  So dS is onto
     and dS^T has the left inverse P/30: (dS)^T m = 0 forces m = 0.
  2. dS annihilates the group-orbit directions: for each of the 10 basis elements
     X_i of the stabilizer algebra, dS(X_i Pi_0) = 0.  The K-orbit lies in the fibre.

Not proved here: the step "(dS)^T m = 0 and P dS^T = 30 I give m = 0" is one line of
matrix algebra (m = (1/30) P (dS^T m)); it is not formalized.  Likewise rank-nullity
(kernel of dS is 32 - 16 = 16 dimensional) and the extension from Pi_0 to every point
of the regular branch (regularity there is the definition of the branch) are not
formalized.  The elimination of the auxiliaries at the level of the field-theoretic
action is not covered.  No physical claim.
-/
set_option autoImplicit false

namespace MultiplierElimination

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


def flat (X : List (List Int)) : List Int := X.flatten

def entriesUpper (g : List (List Int)) : List Int :=
  (List.range 4).flatMap (fun i => (List.range 4).filterMap (fun j =>
    if i ≤ j then some ((g.getD i []).getD j 0) else none))

def entriesStrict (g : List (List Int)) : List Int :=
  (List.range 4).flatMap (fun i => (List.range 4).filterMap (fun j =>
    if i < j then some ((g.getD i []).getD j 0) else none))

-- Differential of S(Pi) = (Pi^T eta Pi, Pi^T Chat Pi) at Pi in the direction V.
def dS (Pi V : List (List Int)) : List Int :=
  let g := madd (mmul (tr V 4) (mmul eta Pi 4) 4) (mmul (tr Pi 4) (mmul eta V 4) 4)
  let f := madd (mmul (tr V 4) (mmul Chat Pi 4) 4) (mmul (tr Pi 4) (mmul Chat V 4) 4)
  entriesUpper g ++ entriesStrict f

def unit32 (idx : Nat) : List (List Int) :=
  (List.range 8).map (fun i => (List.range 4).map (fun j =>
    if i = idx / 4 ∧ j = idx % 4 then (1 : Int) else 0))

-- The 16 x 32 matrix of dS at Pi_0, computed from the definition on the 32 unit directions.
def DSmat : List (List Int) := tr ((List.range 32).map (fun idx => dS Pi0 (unit32 idx))) 16

def preimages : List (List (List Int)) := [
  [[-5, 2, -2, 0],
   [5, 0, 1, 0],
   [-1, -2, 0, 0],
   [-5, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0]],
  [[5, -2, 2, 0],
   [10, 0, -1, 0],
   [1, 2, 0, 0],
   [5, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0]],
  [[5, 10, -10, 0],
   [10, 0, 5, 0],
   [-5, -10, 0, 0],
   [5, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0]],
  [[0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [30, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0]],
  [[5, 13, 2, 0],
   [10, 0, -1, 0],
   [1, 2, 0, 0],
   [5, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0]],
  [[0, -6, 6, 0],
   [0, 0, 12, 0],
   [-12, 6, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0]],
  [[0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 30, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0]],
  [[5, 13, 2, 0],
   [10, 0, -1, 0],
   [1, -13, 0, 0],
   [5, 0, 15, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0]],
  [[0, 0, 0, 30],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 30],
   [60, -30, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0]],
  [[0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 15],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0]],
  [[-5, -10, 10, 0],
   [-10, 0, -5, 0],
   [5, 10, 0, 0],
   [25, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0]],
  [[5, -2, 2, 0],
   [10, 0, -1, 0],
   [-29, 2, 0, 0],
   [5, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0]],
  [[0, 0, 0, 0],
   [0, 0, 0, -30],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [30, 60, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0]],
  [[10, 26, 4, 0],
   [20, 0, -2, 0],
   [2, -26, 0, 0],
   [10, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0]],
  [[0, 0, 0, 30],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [60, -30, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0]],
  [[0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 30],
   [0, 0, 0, 0],
   [0, -30, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0],
   [0, 0, 0, 0]]
]

def Pmat : List (List Int) := preimages.map flat

def basis : List (List (List Int)) := [
  [[-1, -2, 0, 0, 0, 0, 0, 0],
   [-2, 1, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0]],
  [[0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, -1, 0, 0, 0, 0],
   [0, 0, 1, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0]],
  [[0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, -1, 0, 0],
   [0, 0, 0, 0, 1, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0]],
  [[0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 1, 0, 0, 0],
   [0, 0, 0, 0, 0, 1, 0, 0],
   [0, 0, -1, 0, 0, 0, 0, 0],
   [0, 0, 0, -1, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0]],
  [[0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, -1, 0, 0],
   [0, 0, 0, 0, 1, 0, 0, 0],
   [0, 0, 0, -1, 0, 0, 0, 0],
   [0, 0, 1, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0]],
  [[0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 1, 0],
   [0, 0, 0, 0, 0, 0, 0, 1],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, -1, 0, 0, 0, 0, 0],
   [0, 0, 0, -1, 0, 0, 0, 0]],
  [[0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, -1],
   [0, 0, 0, 0, 0, 0, 1, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, -1, 0, 0, 0, 0],
   [0, 0, 1, 0, 0, 0, 0, 0]],
  [[0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 1, 0],
   [0, 0, 0, 0, 0, 0, 0, 1],
   [0, 0, 0, 0, -1, 0, 0, 0],
   [0, 0, 0, 0, 0, -1, 0, 0]],
  [[0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, -1],
   [0, 0, 0, 0, 0, 0, 1, 0],
   [0, 0, 0, 0, 0, -1, 0, 0],
   [0, 0, 0, 0, 1, 0, 0, 0]],
  [[0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, 0],
   [0, 0, 0, 0, 0, 0, 0, -1],
   [0, 0, 0, 0, 0, 0, 1, 0]]
]

theorem DS_times_Pt : mmul DSmat (tr Pmat 32) 16 = mscale 30 (idMat 16) := by decide +kernel

theorem P_times_DSt : mmul Pmat (tr DSmat 32) 16 = mscale 30 (idMat 16) := by decide +kernel

theorem orbit_directions_in_fibre :
    basis.map (fun X => dS Pi0 (mmul X Pi0 4)) = List.replicate 10 (List.replicate 16 0) := by
  decide +kernel

end MultiplierElimination

#print axioms MultiplierElimination.DS_times_Pt
#print axioms MultiplierElimination.P_times_DSt
#print axioms MultiplierElimination.orbit_directions_in_fibre
