import Init.Data.Rat.Basic
import proofs.FourierPairing010g

/-!
# Minimum Mechanics 010g — nonlinear canonical Poisson of Laurent monomials

This construction goes beyond the affine-observable bracket certified in 010f.
A monomial is c*q^m*p^n, with integer Laurent exponents m,n. Its explicit
canonical bracket with d*q^r*p^s is
    {c q^m p^n, d q^r p^s}
       = c d (m s - n r) q^(m+r-1) p^(n+s-1).
The statement is formal algebra, not yet a theorem about smooth function
spaces or distribution-valued field brackets.

The certificate proves the coefficientwise Jacobi identity for arbitrary
Laurent monomials, and its finite-polynomial extension, using exact
integer arithmetic; it supplies a genuinely nonlinear witness.

A polynomial is represented by a finite list, whose coefficient at
each requested exponent address is the authoritative reader; different
lists can encode the same polynomial. The Jacobi claim is about that reader.
-/

set_option autoImplicit false

namespace LaurentPoisson010g

structure Mono where
  q : Int
  p : Int
  coeff : Int
  deriving DecidableEq, Repr

def zeroCoeff (m : Mono) : Mono := ⟨m.q,m.p,0⟩
def unitQ : Mono := ⟨1,0,1⟩
def unitP : Mono := ⟨0,1,1⟩
def qSquared : Mono := ⟨2,0,1⟩
def pSquared : Mono := ⟨0,2,1⟩

def det (a b : Mono) : Int :=
  a.q * b.p - a.p * b.q

def pb (a b : Mono) : Mono :=
  ⟨a.q+b.q-1,a.p+b.p-1,a.coeff*b.coeff*det a b⟩

theorem pb_qp : pb unitQ unitP = ⟨0,0,1⟩ := by decide
theorem pb_pq : pb unitP unitQ = ⟨0,0,-1⟩ := by decide
theorem pb_q2_p2 : pb qSquared pSquared = ⟨1,1,4⟩ := by decide
theorem nonlinear_bracket_witness :
    (pb qSquared pSquared).coeff = 4 := by decide

theorem pb_exponent_symm (a b : Mono) :
    (pb a b).q = (pb b a).q ∧
    (pb a b).p = (pb b a).p := by
  simp [pb]
  omega

theorem det_skew (a b : Mono) : det a b = -det b a := by
  simp only [det]
  rw [Int.mul_comm b.q a.p, Int.mul_comm b.p a.q]
  omega

theorem pb_coefficient_skew (a b : Mono) :
    (pb a b).coeff = -(pb b a).coeff := by
  simp only [pb]
  rw [det_skew a b]
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc, Int.mul_neg]
  omega

-- The degree shift is identical for all three nested brackets.
theorem nested_q_exponent (a b c : Mono) :
    (pb (pb a b) c).q = (pb (pb b c) a).q ∧
    (pb (pb b c) a).q = (pb (pb c a) b).q := by
  simp [pb]
  omega

theorem nested_p_exponent (a b c : Mono) :
    (pb (pb a b) c).p = (pb (pb b c) a).p ∧
    (pb (pb b c) a).p = (pb (pb c a) b).p := by
  simp [pb]
  omega

-- The Jacobi coefficient has an exact determinant identity; no single
-- monomial Jacobi closure is declared until this identity is proved.
theorem det_jacobi (a b c : Mono) :
    det a b *
      ((a.q+b.q-1)*c.p-(a.p+b.p-1)*c.q) +
    det b c *
      ((b.q+c.q-1)*a.p-(b.p+c.p-1)*a.q) +
    det c a *
      ((c.q+a.q-1)*b.p-(c.p+a.p-1)*b.q) = 0 := by
  simp only [det]
  simp only [Int.mul_add,Int.mul_sub,Int.add_mul,Int.sub_mul,
    Int.mul_assoc,Int.neg_mul,Int.mul_neg]
  simp only [Int.mul_comm,Int.mul_left_comm,Int.mul_assoc]
  simp only [← Int.mul_assoc]
  omega

theorem nested_coeff_sum_zero (a b c : Mono) :
    (pb (pb a b) c).coeff +
    (pb (pb b c) a).coeff +
    (pb (pb c a) b).coeff = 0 := by
  have h := det_jacobi a b c
  simp only [pb] at ⊢
  simp only [Int.mul_add, Int.mul_sub, Int.add_mul, Int.sub_mul,
    Int.mul_assoc, Int.neg_mul, Int.mul_neg] at ⊢ h
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc] at ⊢ h
  simp only [← Int.mul_assoc] at ⊢ h
  -- Multiplying the previously proved determinant cancellation by all
  -- three monomial coefficients closes the general weighted case.
  have hw : (a.coeff*b.coeff*c.coeff) * 0 = 0 := by omega
  have hh := congrArg (fun z : Int => (a.coeff*b.coeff*c.coeff)*z) h
  simp only [Int.mul_add, Int.mul_assoc] at hh
  simp only [Int.mul_comm, Int.mul_left_comm, Int.mul_assoc] at hh
  simp only [← Int.mul_assoc] at hh
  omega

def sameExp (m : Mono) (q p : Int) : Prop :=
  m.q = q ∧ m.p = p

def readCoeff (m : Mono) (q p : Int) : Int :=
  if sameExp m q p then m.coeff else 0

-- The nested terms have the same exponent address, and the coefficient
-- sum vanishes there. Thus coefficientwise Jacobi holds for every address.
theorem monomial_jacobi_read (a b c : Mono) (q p : Int) :
    readCoeff (pb (pb a b) c) q p +
    readCoeff (pb (pb b c) a) q p +
    readCoeff (pb (pb c a) b) q p = 0 := by
  have hq := nested_q_exponent a b c
  have hp := nested_p_exponent a b c
  have hc := nested_coeff_sum_zero a b c
  by_cases h : sameExp (pb (pb a b) c) q p
  · have h2 : sameExp (pb (pb b c) a) q p := by
      exact ⟨hq.1.symm.trans h.1,hp.1.symm.trans h.2⟩
    have h3 : sameExp (pb (pb c a) b) q p := by
      exact ⟨hq.2.symm.trans h2.1,hp.2.symm.trans h2.2⟩
    simp only [readCoeff, if_pos h, if_pos h2, if_pos h3]
    exact hc
  · have h2 : ¬sameExp (pb (pb b c) a) q p := by
      intro h2
      exact h ⟨hq.1.trans h2.1,hp.1.trans h2.2⟩
    have h3 : ¬sameExp (pb (pb c a) b) q p := by
      intro h3
      exact h2 ⟨hq.2.trans h3.1,hp.2.trans h3.2⟩
    simp [readCoeff, h, h2, h3]

abbrev Polynomial := List Mono

def finiteJacobi (fs gs hs : Polynomial) (q p : Int) : Int :=
  (fs.map (fun a =>
    (gs.map (fun b =>
      (hs.map (fun c =>
        readCoeff (pb (pb a b) c) q p +
        readCoeff (pb (pb b c) a) q p +
        readCoeff (pb (pb c a) b) q p)).sum)).sum)).sum

theorem finite_laurent_jacobi (fs gs hs : Polynomial) (q p : Int) :
    finiteJacobi fs gs hs q p = 0 := by
  simp only [finiteJacobi]
  have hleaf (a b c : Mono) :
      readCoeff (pb (pb a b) c) q p +
      readCoeff (pb (pb b c) a) q p +
      readCoeff (pb (pb c a) b) q p = 0 :=
    monomial_jacobi_read a b c q p
  induction fs with
  | nil => simp
  | cons a rest ih =>
      simp only [List.map_cons, List.sum_cons]
      have hinner (a : Mono) :
        (gs.map (fun b =>
          (hs.map (fun c =>
            readCoeff (pb (pb a b) c) q p +
            readCoeff (pb (pb b c) a) q p +
            readCoeff (pb (pb c a) b) q p)).sum)).sum = 0 := by
        induction gs with
        | nil => simp
        | cons b others ihg =>
            simp only [List.map_cons, List.sum_cons]
            have hrow :
              (hs.map (fun c =>
                readCoeff (pb (pb a b) c) q p +
                readCoeff (pb (pb b c) a) q p +
                readCoeff (pb (pb c a) b) q p)).sum = 0 := by
              induction hs with
              | nil => simp
              | cons c cs ihh =>
                  simp only [List.map_cons, List.sum_cons]
                  rw [hleaf a b c]
                  simpa using ihh
            rw [hrow, ihg]
            simp
      rw [hinner a]
      simpa using ih

#print axioms det_jacobi
#print axioms pb_coefficient_skew
#print axioms nested_coeff_sum_zero
#print axioms monomial_jacobi_read
#print axioms finite_laurent_jacobi
#print axioms nonlinear_bracket_witness

end LaurentPoisson010g
