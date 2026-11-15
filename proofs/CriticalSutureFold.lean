import proofs.RootCarrier
import proofs.MultiplierElimination

set_option autoImplicit false

/-!
# Critical suture fold: exact metric, flux, reflection, and rank certificates

Carrier: etaHat = G (+) I6, Chat = C (+) C (+) C (+) C.
Pi(0) and Pi(+/- 1/3) come from the regular family SD.11c at a=1.
The interior integer representatives use a last column 4*o4 +/- 3*o5,
whose unscaled rational counterpart is (4/5)*o4 +/- (3/5)*o5.

The two matrix certificates establish rank 15 at the wall and rank 16
at an interior address: a nonzero left annihilator and a scaled
15-dimensional right inverse at the wall; a scaled 16-dimensional right
inverse at the interior address. Every identity is exact integer algebra.

The coefficient identity D-C=T^2 (D+C), D=1+T^2 and C=1-T^2,
is the fraction-linear coordinate z=(1-b)/(1+b)=T^2 when b=C/D.
-/
namespace CriticalSutureFold

open RootCarrier

def wall : List (List Int) := [
 [1,0,0,0], [0,0,0,0], [0,0,1,0], [0,0,0,1],
 [0,0,0,0], [0,0,0,0], [1,0,0,0], [0,1,0,0]]

def plus : List (List Int) := [
 [1,0,0,0], [0,0,0,0], [0,0,1,0], [0,0,0,4],
 [0,0,0,3], [0,0,0,0], [1,0,0,0], [0,1,0,0]]
def minus : List (List Int) := [
 [1,0,0,0], [0,0,0,0], [0,0,1,0], [0,0,0,4],
 [0,0,0,-3], [0,0,0,0], [1,0,0,0], [0,1,0,0]]

def metric (P : List (List Int)) : List (List Int) :=
 mmul (tr P 4) (mmul eta P 4) 4

def flux (P : List (List Int)) : List (List Int) :=
 mmul (tr P 4) (mmul Chat P 4) 4

theorem wall_metric : metric wall =
 [[-1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]] := by decide +kernel

theorem wall_flux : flux wall =
 [[0,-1,0,0],[1,0,0,0],[0,0,0,-1],[0,0,1,0]] := by decide +kernel

theorem plus_metric : metric plus =
 [[-1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,25]] := by decide +kernel

theorem plus_flux : flux plus =
 [[0,-1,0,0],[1,0,0,0],[0,0,0,-4],[0,0,4,0]] := by decide +kernel

def K : List (List Int) :=
 (List.range 8).map (fun i =>
   (List.range 8).map (fun j =>
     if i = j then (if i = 4 || i = 5 then (-1 : Int) else 1) else 0))

theorem K_metric : mmul (tr K 8) (mmul eta K 8) 8 = eta := by decide +kernel
theorem K_flux : mmul (tr K 8) (mmul Chat K 8) 8 = Chat := by decide +kernel
theorem K_exchanges : mmul K plus 4 = minus := by decide +kernel
theorem same_metric : metric plus = metric minus := by decide +kernel
theorem same_flux : flux plus = flux minus := by decide +kernel

def coeff (p : List Int) (k : Nat) : Int := p.getD k 0

def pAdd (p q : List Int) : List Int :=
 (List.range (max p.length q.length)).map (fun i => coeff p i + coeff q i)

def pNeg (p : List Int) : List Int := p.map (fun a => -a)
def pSub (p q : List Int) : List Int := pAdd p (pNeg q)

def pMul (p q : List Int) : List Int :=
 (List.range (p.length + q.length - 1)).map (fun k =>
   ((List.range (k+1)).map (fun i => coeff p i * coeff q (k-i))).foldl
     (fun a b => a+b) 0)

def Dpoly : List Int := [1,0,1]
def Cpoly : List Int := [1,0,-1]
def Spoly : List Int := [0,2]
def T2poly : List Int := [0,0,1]

theorem circle_polynomial :
 (List.range 5).map (fun i => coeff (pMul Dpoly Dpoly) i) =
   (List.range 5).map (fun i =>
     coeff (pAdd (pMul Cpoly Cpoly) (pMul Spoly Spoly)) i) :=
 by decide +kernel

theorem mobius_fold_polynomial :
 (List.range 5).map (fun i => coeff (pSub Dpoly Cpoly) i) =
   (List.range 5).map (fun i =>
     coeff (pMul T2poly (pAdd Dpoly Cpoly)) i) :=
 by decide +kernel

def DS (P : List (List Int)) : List (List Int) :=
 tr ((List.range 32).map (fun k => dS P (MultiplierElimination.unit32 k))) 16

def leftNull : List Int := [0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,2]

theorem wall_left_null :
 mmul [leftNull] (DS wall) 32 = [List.replicate 32 0] :=
 by decide +kernel

theorem left_null_nonzero : leftNull ≠ List.replicate 16 0 := by decide

def select (A : List (List Int)) (rows columns : List Nat) : List (List Int) :=
 rows.map (fun i => columns.map (fun j => (A.getD i []).getD j 0))

structure Entry where
 r : Nat
 c : Nat
 v : Int
 deriving DecidableEq

def sparse (n : Nat) (entries : List Entry) : List (List Int) :=
 (List.range n).map (fun i => (List.range n).map (fun j =>
   entries.foldl (fun total e =>
     if e.r = i && e.c = j then total + e.v else total) (0 : Int)))

def columns15 : List Nat := [0,1,2,3,5,6,7,9,10,11,13,15,26,27,29]

def witness15 : List Entry := [
 ⟨0,0,-1⟩, ⟨1,1,-2⟩, ⟨1,4,-1⟩, ⟨1,10,-2⟩,
 ⟨2,2,-2⟩, ⟨2,6,-2⟩, ⟨2,11,-2⟩, ⟨2,13,2⟩,
 ⟨3,3,-2⟩, ⟨3,5,2⟩, ⟨3,12,-2⟩, ⟨3,14,2⟩,
 ⟨4,4,-2⟩, ⟨4,10,-4⟩, ⟨5,11,-4⟩, ⟨6,12,-4⟩,
 ⟨7,5,4⟩, ⟨8,7,2⟩, ⟨9,8,4⟩, ⟨10,6,4⟩,
 ⟨11,9,2⟩, ⟨12,6,-4⟩, ⟨12,13,4⟩,
 ⟨13,5,4⟩, ⟨13,14,4⟩, ⟨14,4,2⟩]

theorem wall_rank_lower :
 mmul (select (DS wall) (List.range 15) columns15)
    (sparse 15 witness15) 15 = mscale 4 (idMat 15) :=
 by decide +kernel

def columns16 : List Nat := [0,1,2,3,5,6,7,9,10,11,13,15,17,19,21,29]

def witness16 : List Entry := [
 ⟨0,0,-3⟩, ⟨1,1,-6⟩, ⟨1,4,-3⟩, ⟨1,10,-6⟩,
 ⟨2,2,-6⟩, ⟨2,11,-6⟩, ⟨3,3,-6⟩, ⟨3,12,-6⟩,
 ⟨4,4,-6⟩, ⟨4,10,-12⟩, ⟨5,11,-12⟩, ⟨6,12,-12⟩,
 ⟨7,5,12⟩, ⟨8,7,6⟩, ⟨9,8,12⟩, ⟨10,13,12⟩,
 ⟨11,7,-24⟩, ⟨11,15,-12⟩, ⟨12,6,4⟩, ⟨12,13,-16⟩,
 ⟨13,7,32⟩, ⟨13,9,2⟩, ⟨13,15,16⟩,
 ⟨14,5,16⟩, ⟨14,14,4⟩, ⟨15,4,6⟩]

theorem interior_rank_full :
 mmul (select (DS plus) (List.range 16) columns16)
    (sparse 16 witness16) 16 = mscale 12 (idMat 16) :=
 by decide +kernel

structure Certificate : Prop where
 scalar_circle :
   (List.range 5).map (fun i => coeff (pMul Dpoly Dpoly) i) =
   (List.range 5).map (fun i =>
     coeff (pAdd (pMul Cpoly Cpoly) (pMul Spoly Spoly)) i)
 scalar_fold :
   (List.range 5).map (fun i => coeff (pSub Dpoly Cpoly) i) =
   (List.range 5).map (fun i =>
     coeff (pMul T2poly (pAdd Dpoly Cpoly)) i)
 wall_metric : metric wall =
   [[-1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]]
 wall_flux : flux wall =
   [[0,-1,0,0],[1,0,0,0],[0,0,0,-1],[0,0,1,0]]
 gauge_metric : mmul (tr K 8) (mmul eta K 8) 8 = eta
 gauge_flux : mmul (tr K 8) (mmul Chat K 8) 8 = Chat
 gauge_exchange : mmul K plus 4 = minus
 wall_annihilator : mmul [leftNull] (DS wall) 32 = [List.replicate 32 0]
 rank15_lower : mmul (select (DS wall) (List.range 15) columns15)
   (sparse 15 witness15) 15 = mscale 4 (idMat 15)
 rank16_interior : mmul (select (DS plus) (List.range 16) columns16)
   (sparse 16 witness16) 16 = mscale 12 (idMat 16)

theorem critical_suture_fold : Certificate :=
 { scalar_circle := circle_polynomial
   scalar_fold := mobius_fold_polynomial
   wall_metric := wall_metric
   wall_flux := wall_flux
   gauge_metric := K_metric
   gauge_flux := K_flux
   gauge_exchange := K_exchanges
   wall_annihilator := wall_left_null
   rank15_lower := wall_rank_lower
   rank16_interior := interior_rank_full }

end CriticalSutureFold

#print axioms CriticalSutureFold.critical_suture_fold
