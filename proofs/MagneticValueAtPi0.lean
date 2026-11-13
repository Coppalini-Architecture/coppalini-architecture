/-!
# Magnetic invariant at Pi_0

Integer linear algebra only.  Core Lean 4, no Mathlib, `decide +kernel`.

With the carrier of `RootCarrier.lean`, at Pi_0 let
  h = Pi_0^T eta Pi_0   (induced form, det h = -7),
  F = Pi_0^T Chat Pi_0  (induced 2-form),
  A = adj(h),  so that  h A = A h = -7 I.
The inverse form is h^{-1} = A / (-7), hence
  F_ab F^ab = tr(F^T h^{-1} F h^{-1}) = tr(F^T A F A) / 49.

Proved here
  1. F = [[0,-1,0,0],[1,0,-1,0],[0,1,0,0],[0,0,0,0]] and F^T = -F.
  2. h A = A h = -7 I   (A is the adjugate, so h^{-1} = A/(-7)).
  3. Pf F = F01 F23 - F02 F13 + F03 F12 = 0   (F wedge F = 0: decomposable).
  4. tr(F^T A F A) = 14, so  (1/2) F_ab F^ab = 14 / (2 * 49) = 1/7.
  5. 14 < 2 * 49, i.e. b^2 = 1/7 < 1 = chi^2 (the regular-branch bound).

Reading: with b taken as the magnetic invariant sqrt((1/2) F_ab F^ab) (the field
is purely magnetic because Pf F = 0 and the invariant is positive), b = 1/sqrt 7.
That reading of b, and chi = 1, are the paper's conventions as I took them;
only the rational statements above are decided here.  No physical claim.
-/
set_option autoImplicit false

namespace MagneticInvariant

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


def trace (M : List (List Int)) : Int :=
  ((List.range M.length).map (fun i => (M.getD i []).getD i 0)).foldl (fun (s x : Int) => s + x) 0

def ent (M : List (List Int)) (i j : Nat) : Int := (M.getD i []).getD j 0

def h : List (List Int) := mmul (tr Pi0 4) (mmul eta Pi0 4) 4
def F : List (List Int) := mmul (tr Pi0 4) (mmul Chat Pi0 4) 4

def A : List (List Int) :=
  [[3, -1, 0, 0], [-1, -2, 0, 0], [0, 0, -7, 0], [0, 0, 0, -7]]

theorem F_value :
    F = [[0, -1, 0, 0], [1, 0, -1, 0], [0, 1, 0, 0], [0, 0, 0, 0]] := by decide +kernel

theorem F_antisymmetric : madd F (tr F 4) = zerosMat 4 4 := by decide +kernel

theorem h_adjugate_right : mmul h A 4 = mscale (-7) (idMat 4) := by decide +kernel

theorem h_adjugate_left : mmul A h 4 = mscale (-7) (idMat 4) := by decide +kernel

theorem pfaffian_zero :
    ent F 0 1 * ent F 2 3 - ent F 0 2 * ent F 1 3 + ent F 0 3 * ent F 1 2 = 0 := by
  decide +kernel

-- (1/2) F_ab F^ab = tr(F^T A F A) / (2 * 49) = 14 / 98 = 1/7.
theorem invariant_numerator :
    trace (mmul (mmul (tr F 4) A 4) (mmul F A 4) 4) = 14 := by decide +kernel

-- b^2 = 14 / (2 * 49) < 1 = chi^2.
theorem regular_domain : (14 : Int) < 2 * 49 := by decide

end MagneticInvariant

#print axioms MagneticInvariant.F_value
#print axioms MagneticInvariant.h_adjugate_right
#print axioms MagneticInvariant.invariant_numerator
