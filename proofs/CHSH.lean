/-!
# CHSH carrier from the root reflections

Integer linear algebra only.  Core Lean 4, no Mathlib, `decide +kernel`.

With Gt = G = [[-2,1],[1,2]] and St = 2Q - I = [[1,2],[2,-1]]:
  H = Gt/sqrt 5,  S = St/sqrt 5,  H^2 = S^2 = I,  H S = C = -S H.
Observables A = H, A' = S, B = (H+S)/sqrt 2, B' = (H-S)/sqrt 2 give
  CHSH = A(x)B + A(x)B' + A'(x)B - A'(x)B' = (sqrt 2 / 5) K,
  K = Gt(x)Gt + St(x)St   (an integer matrix).

Everything below is an integer identity; sqrt 2 and sqrt 5 appear only
in these comments.
  * Gt^2 = St^2 = 5 I,  Gt St = 5 C,  St Gt = -5 C
  * four-term sum of scaled tensor products = 2 K
  * K^2 = 50 (I + C(x)C)  and  (I + C(x)C)^2 = 2 (I + C(x)C)
    hence CHSH^4 = 8 CHSH^2, spectrum inside {0, +-2 sqrt 2}
  * 200 I - 2 K^2 = 50 M^T M with M = I - C(x)C symmetric,
    hence CHSH^2 <= 8 I: the Tsirelson bound 2 sqrt 2 is not exceeded
  * for the Bell vector v = (1,0,0,1): v^T K v = 20, so
    <Phi+|CHSH|Phi+> = (sqrt 2 / 5)(20/2) = 2 sqrt 2 (the bound is attained)
No physical claim; spectral and positivity readings are consequences of the
displayed identities.
-/
set_option autoImplicit false

namespace CHSH

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

def kron (A B : List (List Int)) : List (List Int) :=
  A.flatMap (fun ra => B.map (fun rb => ra.flatMap (fun a => rb.map (fun b => a * b))))

def Gt : List (List Int) := [[-2, 1], [1, 2]]
def St : List (List Int) := [[1, 2], [2, -1]]
def Cm : List (List Int) := [[0, -1], [1, 0]]

theorem Gt_square : mmul Gt Gt 2 = mscale 5 (idMat 2) := by decide +kernel
theorem St_square : mmul St St 2 = mscale 5 (idMat 2) := by decide +kernel
theorem Gt_St : mmul Gt St 2 = mscale 5 Cm := by decide +kernel
theorem St_Gt : mmul St Gt 2 = mscale (-5) Cm := by decide +kernel

def K : List (List Int) := madd (kron Gt Gt) (kron St St)
def XX : List (List Int) := kron Cm Cm
def Pm : List (List Int) := madd (idMat 4) XX
def Mm : List (List Int) := madd (idMat 4) (mscale (-1) XX)

def B1 : List (List Int) := madd Gt St
def B2 : List (List Int) := madd Gt (mscale (-1) St)

-- Gt(x)(Gt+St) + Gt(x)(Gt-St) + St(x)(Gt+St) - St(x)(Gt-St) = 2 K
theorem four_term_sum :
    madd (madd (kron Gt B1) (kron Gt B2))
         (madd (kron St B1) (mscale (-1) (kron St B2))) = mscale 2 K := by decide +kernel

theorem K_square : mmul K K 4 = mscale 50 Pm := by decide +kernel

theorem Pm_idempotent_up_to_two : mmul Pm Pm 4 = mscale 2 Pm := by decide +kernel

theorem Mm_symmetric : tr Mm 4 = Mm := by decide +kernel

-- 200 I - 2 K^2 = 50 M^T M : CHSH^2 = (2/25) K^2 <= 8 I.
theorem tsirelson_certificate :
    madd (mscale 200 (idMat 4)) (mscale (-2) (mmul K K 4))
      = mscale 50 (mmul (tr Mm 4) Mm 4) := by decide +kernel

def bell : List Int := [1, 0, 0, 1]

theorem bell_expectation_scaled : dot bell (K.map (fun r => dot r bell)) = 20 := by
  decide +kernel

end CHSH

#print axioms CHSH.four_term_sum
#print axioms CHSH.K_square
#print axioms CHSH.tsirelson_certificate
#print axioms CHSH.bell_expectation_scaled
