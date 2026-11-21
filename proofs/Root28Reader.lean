/-!
# Root28: finite reader structure

This module checks the *reader* rather than claiming a new field theorem.
It proves, in Lean's kernel:

1. the declared 28-card scan is complete and has no duplicate address;
2. every card has the stated `(a,b)` address in `Z7 × Z4`;
3. the retained card-status partition is exact;
4. the integer core identities used by the finite cards.

Continuous transport, the source-documented smooth completion, the geometric
cup, and any external formalization retain their own source/status boundaries.
No claim about zeta or the Riemann Hypothesis occurs in this file.
-/

set_option autoImplicit false

namespace Root28Reader

/-! Canonical SHA-256 of `research/metric-minimum-root28-v0.1.json`.
The Python receipt verifies this binding before invoking the finite reader
checks; changing the manifest therefore requires a fresh Lean source build. -/
def manifestSha256 : String :=
  "1f0e02d6be0fba44efabe67bc700d178e2624a4d585b8989dd2f466f9fef6ef1"

theorem manifest_sha256_declared :
    manifestSha256 = "1f0e02d6be0fba44efabe67bc700d178e2624a4d585b8989dd2f466f9fef6ef1" := rfl

inductive CardKind where
  | exactFinite
  | exactDerived
  | declaredCarrier
  | openBoundary
  deriving DecidableEq, Repr

structure Card where
  q : Nat
  a : Nat
  b : Nat
  kind : CardKind
  deriving DecidableEq, Repr

def scanA (q : Nat) : Nat := q % 7
def scanB (q : Nat) : Nat := q % 4
def inverseScan (a b : Nat) : Nat := (8 * a + 21 * b) % 28

/-! The cards are listed in scanner order `q = 0,…,27`.  Text, source
locators, and boundaries live in `research/metric-minimum-root28-v0.1.json`.
The Lean carrier intentionally holds only the finite address and status data. -/
def cards : List Card := [
  ⟨0, 0, 0, .exactFinite⟩,
  ⟨1, 1, 1, .exactFinite⟩,
  ⟨2, 2, 2, .exactFinite⟩,
  ⟨3, 3, 3, .openBoundary⟩,
  ⟨4, 4, 0, .exactDerived⟩,
  ⟨5, 5, 1, .exactDerived⟩,
  ⟨6, 6, 2, .exactDerived⟩,
  ⟨7, 0, 3, .openBoundary⟩,
  ⟨8, 1, 0, .exactFinite⟩,
  ⟨9, 2, 1, .exactFinite⟩,
  ⟨10, 3, 2, .exactDerived⟩,
  ⟨11, 4, 3, .openBoundary⟩,
  ⟨12, 5, 0, .exactDerived⟩,
  ⟨13, 6, 1, .exactFinite⟩,
  ⟨14, 0, 2, .exactDerived⟩,
  ⟨15, 1, 3, .openBoundary⟩,
  ⟨16, 2, 0, .exactFinite⟩,
  ⟨17, 3, 1, .exactFinite⟩,
  ⟨18, 4, 2, .exactDerived⟩,
  ⟨19, 5, 3, .openBoundary⟩,
  ⟨20, 6, 0, .declaredCarrier⟩,
  ⟨21, 0, 1, .exactFinite⟩,
  ⟨22, 1, 2, .exactFinite⟩,
  ⟨23, 2, 3, .openBoundary⟩,
  ⟨24, 3, 0, .exactFinite⟩,
  ⟨25, 4, 1, .exactDerived⟩,
  ⟨26, 5, 2, .exactDerived⟩,
  ⟨27, 6, 3, .openBoundary⟩
]

def cardAddresses : List Nat := cards.map Card.q
def cardPairs : List (Nat × Nat) := cards.map (fun c => (c.a, c.b))
def allScanned : Bool := cards.all (fun c =>
  c.a == scanA c.q && c.b == scanB c.q && inverseScan c.a c.b == c.q)

def exactFiniteAddresses : List Nat :=
  cards.filter (fun c => c.kind == .exactFinite) |>.map Card.q
def exactDerivedAddresses : List Nat :=
  cards.filter (fun c => c.kind == .exactDerived) |>.map Card.q
def declaredCarrierAddresses : List Nat :=
  cards.filter (fun c => c.kind == .declaredCarrier) |>.map Card.q
def openBoundaryAddresses : List Nat :=
  cards.filter (fun c => c.kind == .openBoundary) |>.map Card.q

theorem card_count : cards.length = 28 := by decide +kernel
theorem addresses_complete : cardAddresses = List.range 28 := by decide +kernel
theorem addresses_unique : cardAddresses.eraseDups = List.range 28 := by decide +kernel
theorem scanner_agrees : allScanned = true := by decide +kernel
theorem pairs_unique : cardPairs.eraseDups.length = 28 := by decide +kernel

/-! The status partition is itself a reader obligation.  It prevents a
source declaration or an open boundary from being silently promoted into a
finite theorem. -/
theorem exact_finite_card_set :
    exactFiniteAddresses = [0, 1, 2, 8, 9, 13, 16, 17, 21, 22, 24] := by
  decide +kernel

theorem exact_derived_card_set :
    exactDerivedAddresses = [4, 5, 6, 10, 12, 14, 18, 25, 26] := by
  decide +kernel

theorem declared_carrier_card_set : declaredCarrierAddresses = [20] := by
  decide +kernel

theorem open_boundary_card_set :
    openBoundaryAddresses = [3, 7, 11, 15, 19, 23, 27] := by
  decide +kernel

/-! ## Integer core used by the finite cards -/

structure Mat2 where
  a : Int
  b : Int
  c : Int
  d : Int
  deriving DecidableEq, Repr

def mmul (u v : Mat2) : Mat2 :=
  ⟨u.a * v.a + u.b * v.c, u.a * v.b + u.b * v.d,
   u.c * v.a + u.d * v.c, u.c * v.b + u.d * v.d⟩

def madd (u v : Mat2) : Mat2 := ⟨u.a + v.a, u.b + v.b, u.c + v.c, u.d + v.d⟩
def mneg (u : Mat2) : Mat2 := ⟨-u.a, -u.b, -u.c, -u.d⟩
def mscale (k : Int) (u : Mat2) : Mat2 := ⟨k*u.a, k*u.b, k*u.c, k*u.d⟩
def mtranspose (u : Mat2) : Mat2 := ⟨u.a, u.c, u.b, u.d⟩
def comm (u v : Mat2) : Mat2 := madd (mmul u v) (mneg (mmul v u))
def det (u : Mat2) : Int := u.a * u.d - u.b * u.c

def I2 : Mat2 := ⟨1, 0, 0, 1⟩
def Q : Mat2 := ⟨1, 1, 1, 0⟩
def Jrot : Mat2 := ⟨0, -1, 1, 0⟩
def Omega : Mat2 := ⟨0, 1, -1, 0⟩
def G : Mat2 := ⟨-2, 1, 1, 2⟩
def Aax : Mat2 := madd Q (mscale 2 I2)

theorem q_recurrence : mmul Q Q = madd Q I2 := by decide +kernel
theorem q_det : det Q = -1 := by decide +kernel
theorem j_is_minus_omega : Jrot = mneg Omega := by decide +kernel
theorem j_square : mmul Jrot Jrot = mneg I2 := by decide +kernel
theorem j_orthogonal : mmul (mtranspose Jrot) Jrot = I2 := by decide +kernel
theorem omega_skew : mtranspose Omega = mneg Omega := by decide +kernel
theorem omega_square : mmul Omega Omega = mneg I2 := by decide +kernel
theorem omega_q_character : mmul (mmul (mtranspose Q) Omega) Q = mneg Omega := by decide +kernel
theorem g_commutator : comm Q Omega = G := by decide +kernel
theorem g_symmetric : mtranspose G = G := by decide +kernel
theorem g_square : mmul G G = mscale 5 I2 := by decide +kernel
theorem g_det : det G = -5 := by decide +kernel
theorem q_signed_metric : mmul (mmul (mtranspose Q) G) Q = mneg G := by decide +kernel
theorem j_signed_metric : mmul (mmul (mtranspose Jrot) G) Jrot = mneg G := by decide +kernel

/-! `Aax = sqrt(5) * L_ax` is the integer representative of the axial
transport.  These scaled identities are the exact finite certificate behind
the normalized formulas in the source. -/
theorem axial_scaled_metric :
    mmul (mmul (mtranspose Aax) G) Aax = mscale 5 G := by decide +kernel

theorem axial_scaled_mirror :
    mmul (mmul G Aax) G = ⟨10, -5, -5, 15⟩ := by decide +kernel

/-! The discrete wheel reader checks phase recurrence and retains the carried
advance as a separate address.  The source attaches `Aax/sqrt(5)=L_ax`. -/
def phaseAfter (phase steps : Nat) : Nat := (phase + steps) % 4
theorem wheel_phase_four (phase : Nat) : phaseAfter phase 4 = phase % 4 := by
  simp [phaseAfter]

/-! The module's final proposition is deliberately structural.  It is the
Lean-checkable punchcard claim for this edition. -/
theorem root28_punchcard :
    cards.length = 28 ∧
    cardAddresses = List.range 28 ∧
    allScanned = true ∧
    openBoundaryAddresses = [3, 7, 11, 15, 19, 23, 27] ∧
    mmul G G = mscale 5 I2 := by
  exact ⟨card_count, addresses_complete, scanner_agrees, open_boundary_card_set, g_square⟩

end Root28Reader

#print axioms Root28Reader.root28_punchcard
