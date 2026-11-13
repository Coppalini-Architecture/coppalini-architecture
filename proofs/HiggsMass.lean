/-!
# Higgs-induced gauge-boson mass operator: exact polynomial identities

Core Lean 4, no Mathlib, `decide +kernel`.  The symbols g, g', v are formal
variables of the polynomial ring Z[g, g', v], represented as normalized lists
of monomials (exponents of g, g', v, and an integer coefficient); equality of
normalized lists is decided by the kernel, in the same way `Z[sqrt 5]` was
represented by integer pairs.

Operator.  For the fields (W1, W2, W3, B) the Higgs-induced mass quadratic form is
  L = (v^2/8) ( g^2 (W1^2 + W2^2) + (g W3 - g' B)^2 ),
and its Hessian is M2 = (v^2/4) [[g^2,0,0,0],[0,g^2,0,0],[0,0,g^2,-g g'],[0,0,-g g',g'^2]].
Below M4 = 4 M2 (integer polynomial entries).

Proved here
  1. M4 = v^2 R^T R  with  R = [[g,0,0,0],[0,g,0,0],[0,0,g,-g']]   (Gram form of L)
  2. M4 (0,0,g',g)^T = 0                                           (photon direction)
  3. M4 e1 = v^2 g^2 e1,  M4 e2 = v^2 g^2 e2,
     M4 (0,0,g,-g')^T = v^2 (g^2 + g'^2) (0,0,g,-g')^T              (three massive directions)
  4. (0,0,g',g) . (0,0,g,-g') = 0                                   (orthogonality)
  5. trace M4 = 2 v^2 g^2 + v^2 (g^2 + g'^2)                         (eigenvalue sum)
  6. the 3x3 minor of R on its first three columns is g^3, a nonzero
     polynomial: over Q(g, g', v) the matrix R has rank 3, so the kernel
     of M4 is exactly one-dimensional.

Not proved here: the differentiation that produces M2 from L (checked in SymPy:
4 Hess(L) = M4, and M4 = v^2 R^T R), and the choice of the u(2) plane that
embeds the electroweak carrier.  Tree level only; no numerical prediction.
-/
set_option autoImplicit false

namespace HiggsMass

structure Mono where
  a : Nat
  b : Nat
  c : Nat
  k : Int
  deriving DecidableEq, Repr

def sameMono (s t : Mono) : Bool :=
  Nat.beq s.a t.a && Nat.beq s.b t.b && Nat.beq s.c t.c

def monoLt (s t : Mono) : Bool :=
  Nat.blt s.a t.a ||
    (Nat.beq s.a t.a && (Nat.blt s.b t.b || (Nat.beq s.b t.b && Nat.blt s.c t.c)))

def insertTerm (t : Mono) : List Mono → List Mono
  | [] => if t.k = 0 then [] else [t]
  | s :: rest =>
    if sameMono t s then
      (if t.k + s.k = 0 then rest else { s with k := t.k + s.k } :: rest)
    else if monoLt t s then
      (if t.k = 0 then s :: rest else t :: s :: rest)
    else s :: insertTerm t rest

def padd (p q : List Mono) : List Mono :=
  q.foldl (fun acc t => insertTerm t acc) p

def pneg (p : List Mono) : List Mono :=
  p.map (fun t => { t with k := -t.k })

def pmulTerm (s t : Mono) : Mono :=
  ⟨s.a + t.a, s.b + t.b, s.c + t.c, s.k * t.k⟩

def pmul (p q : List Mono) : List Mono :=
  p.foldl (fun acc s => q.foldl (fun acc2 t => insertTerm (pmulTerm s t) acc2) acc) []

def pdot (u v : List (List Mono)) : List Mono :=
  (List.zipWith (fun (x y : List Mono) => pmul x y) u v).foldl
    (fun (acc x : List Mono) => padd acc x) []

def pcol (B : List (List (List Mono))) (j : Nat) : List (List Mono) :=
  B.map (fun r => r.getD j [])

def pmmul (A B : List (List (List Mono))) (n : Nat) : List (List (List Mono)) :=
  A.map (fun r => (List.range n).map (fun j => pdot r (pcol B j)))

def ptr (A : List (List (List Mono))) (n : Nat) : List (List (List Mono)) :=
  (List.range n).map (fun j => pcol A j)

def pscale (s : List Mono) (M : List (List (List Mono))) : List (List (List Mono)) :=
  M.map (fun r => r.map (fun x => pmul s x))

def pmatvec (M : List (List (List Mono))) (u : List (List Mono)) : List (List Mono) :=
  M.map (fun r => pdot r u)

def entry (M : List (List (List Mono))) (i j : Nat) : List Mono :=
  (M.getD i []).getD j []

def pconst (n : Int) : List Mono := if n = 0 then [] else [⟨0, 0, 0, n⟩]

def z : List Mono := []
def pg : List Mono := [⟨1, 0, 0, 1⟩]
def pgp : List Mono := [⟨0, 1, 0, 1⟩]
def pv : List Mono := [⟨0, 0, 1, 1⟩]

def v2 : List Mono := pmul pv pv
def g2 : List Mono := pmul pg pg
def gp2 : List Mono := pmul pgp pgp
def ggp : List Mono := pmul pg pgp

def R : List (List (List Mono)) :=
  [[pg, z, z, z], [z, pg, z, z], [z, z, pg, pneg pgp]]

def Rt : List (List (List Mono)) := ptr R 4

def M4 : List (List (List Mono)) :=
  [[pmul v2 g2, z, z, z],
   [z, pmul v2 g2, z, z],
   [z, z, pmul v2 g2, pneg (pmul v2 ggp)],
   [z, z, pneg (pmul v2 ggp), pmul v2 gp2]]

def kv : List (List Mono) := [z, z, pgp, pg]
def uv : List (List Mono) := [z, z, pg, pneg pgp]
def e1 : List (List Mono) := [pconst 1, z, z, z]
def e2 : List (List Mono) := [z, pconst 1, z, z]

def mw : List Mono := pmul v2 g2
def lam : List Mono := pmul v2 (padd g2 gp2)

def det3 (a b c d e f g h i : List Mono) : List Mono :=
  padd (padd (pmul a (padd (pmul e i) (pneg (pmul f h))))
             (pneg (pmul b (padd (pmul d i) (pneg (pmul f g))))))
       (pmul c (padd (pmul d h) (pneg (pmul e g))))

/-! ## Gram factorization -/

theorem M4_gram : M4 = pscale v2 (pmmul Rt R 4) := by decide +kernel

/-! ## Spectrum of M4 -/

theorem photon_kernel : pmatvec M4 kv = [z, z, z, z] := by decide +kernel

theorem massive_e1 : pmatvec M4 e1 = e1.map (fun x => pmul mw x) := by decide +kernel

theorem massive_e2 : pmatvec M4 e2 = e2.map (fun x => pmul mw x) := by decide +kernel

theorem massive_u : pmatvec M4 uv = uv.map (fun x => pmul lam x) := by decide +kernel

theorem photon_orthogonal_to_massive : pdot kv uv = [] := by decide +kernel

theorem trace_is_eigenvalue_sum :
    padd (padd (padd (entry M4 0 0) (entry M4 1 1)) (entry M4 2 2)) (entry M4 3 3)
      = padd (padd mw mw) lam := by decide +kernel

/-! ## Rank: the kernel is exactly one-dimensional over Q(g, g', v) -/

theorem R_minor_is_g_cubed :
    det3 (entry R 0 0) (entry R 0 1) (entry R 0 2)
         (entry R 1 0) (entry R 1 1) (entry R 1 2)
         (entry R 2 0) (entry R 2 1) (entry R 2 2) = [⟨3, 0, 0, 1⟩] := by decide +kernel

end HiggsMass

#print axioms HiggsMass.M4_gram
#print axioms HiggsMass.photon_kernel
#print axioms HiggsMass.massive_u
#print axioms HiggsMass.R_minor_is_g_cubed
