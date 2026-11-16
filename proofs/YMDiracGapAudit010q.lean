import Init.Data.Rat.Basic

/-!
# Minimum Mechanics 010q — Yang–Mills Dirac/gap implication audit

Fixed reference: 010a–010p are unchanged. The mass-gap obligation
has NOT been discharged. This file checks a load-bearing implication:

    Non-Abelian first-class Gauss algebra + invariant energy
           does not imply a uniform positive spectral gap.

The SO(3) spin-1 generators below furnish a noncommutative
representation of su(2) (with the usual compact real form).
In the corresponding complex Hilbert representation,
self-adjoint generators are -i times these real skew matrices.

For the physical gauge-singlet sector use the separable Hilbert space
  C|Omega> ⊕ l²(N),
with H|Omega>=0 and H|n>=1/(n+1)|n>.
Add a charged C³ triplet on which the displayed Gauss matrices act.
Then the gauge constraints act nontrivially, their commutators close,
the physical vacuum is unique, and positive energies accumulate at 0.
The direct-sum Hilbert construction and operator self-adjointness are
ordinary mathematical facts specified in the accompanying proof note;
this core Lean certificate checks the exact matrix algebra and
Archimedean spectral inequality, NOT an infinite-dimensional Hilbert
type or a construction of 4D quantum Yang–Mills.

The rational gap threshold delta=p/q, p,q>0, would require
  1/(n+1) >= p/q  for every n,
equivalently
  p*(n+1) <= q  for every n.
The final Lean theorem explicitly refutes this for every p,q>0.

This is a non-entailment result for the ADM–Dirac/Gauss identity
structure. It does not solve the Yang–Mills mass-gap problem.

Lean 4.33.0, no sorry, no new axioms, no Mathlib.
-/

set_option autoImplicit false

namespace YMDiracGapAudit010q

abbrev Axis := Fin 3
abbrev Mat3 := Axis → Axis → Int

def Jx : Mat3 := fun i j =>
  if i=1 ∧ j=2 then -1
  else if i=2 ∧ j=1 then 1
  else 0

def Jy : Mat3 := fun i j =>
  if i=0 ∧ j=2 then 1
  else if i=2 ∧ j=0 then -1
  else 0

def Jz : Mat3 := fun i j =>
  if i=0 ∧ j=1 then -1
  else if i=1 ∧ j=0 then 1
  else 0

def mul (A B : Mat3) : Mat3 := fun i j =>
  A i 0*B 0 j + A i 1*B 1 j + A i 2*B 2 j

def sub (A B : Mat3) : Mat3 := fun i j =>
  A i j - B i j

def bracket (A B : Mat3) : Mat3 := sub (mul A B) (mul B A)

private theorem axis_cases : ∀ i : Axis,
    i=0 ∨ i=1 ∨ i=2 := by decide

theorem nonabelian_xy : bracket Jx Jy = Jz := by
  funext i j
  rcases axis_cases i with hi | hi | hi <;>
    rcases axis_cases j with hj | hj | hj <;>
    subst i <;> subst j <;>
    decide

theorem nonabelian_yz : bracket Jy Jz = Jx := by
  funext i j
  rcases axis_cases i with hi | hi | hi <;>
    rcases axis_cases j with hj | hj | hj <;>
    subst i <;> subst j <;>
    decide

theorem nonabelian_zx : bracket Jz Jx = Jy := by
  funext i j
  rcases axis_cases i with hi | hi | hi <;>
    rcases axis_cases j with hj | hj | hj <;>
    subst i <;> subst j <;>
    decide

theorem genuinely_nonabelian :
    bracket Jx Jy ≠ (fun _ _ => 0) := by
  intro h
  rw [nonabelian_xy] at h
  have hxy := congrFun (congrFun h 0) 1
  simp [Jz] at hxy

-- For a positive rational candidate p/q (q>0), arbitrarily high
-- excited singlet addresses n give a smaller positive energy 1/(n+1).
theorem energy_below_any_positive_rational_threshold
    (p q : Nat) (hp : 0 < p) (hq : 0 < q) :
    ∃ n : Nat, q < p * (n+1) := by
  have hsmall : 1 ≤ p := by omega
  have hmul : 1*(q+1) ≤ p*(q+1) :=
    Nat.mul_le_mul_right (q+1) hsmall
  refine ⟨q, ?_⟩
  omega

-- A uniform spectral bound p/q>0 on ALL physical excited singlets
-- would demand p*(n+1)≤q for every n. Such a bound fails exactly.
theorem no_positive_uniform_gap_from_gauss_algebra
    (p q : Nat) (hp : 0 < p) (hq : 0 < q) :
    ¬(∀ n : Nat, p*(n+1) ≤ q) := by
  intro hgap
  obtain ⟨n, hn⟩ :=
    energy_below_any_positive_rational_threshold p q hp hq
  have hb := hgap n
  omega

-- A simple exact vacuum-address ledger. The vacuum energy is zero,
-- and every positive integer address n has an eigenvalue 1/(n+1)
-- in the mathematical Hilbert realization described above.
inductive PhysicalAddress where
  | vacuum
  | excited (n : Nat)
  deriving DecidableEq, Repr

def spectralDenominator : PhysicalAddress → Nat
  | .vacuum => 0
  | .excited n => n+1

theorem vacuum_has_separate_address :
    spectralDenominator PhysicalAddress.vacuum = 0 := rfl

theorem every_excited_address_positive (n : Nat) :
    0 < spectralDenominator (.excited n) := by
  simp [spectralDenominator]

#print axioms nonabelian_xy
#print axioms nonabelian_yz
#print axioms nonabelian_zx
#print axioms genuinely_nonabelian
#print axioms energy_below_any_positive_rational_threshold
#print axioms no_positive_uniform_gap_from_gauss_algebra
#print axioms vacuum_has_separate_address
#print axioms every_excited_address_positive

end YMDiracGapAudit010q
