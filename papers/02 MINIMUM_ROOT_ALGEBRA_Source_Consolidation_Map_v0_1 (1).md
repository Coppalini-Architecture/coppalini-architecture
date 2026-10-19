# MINIMUM ROOT ALGEBRA
## Source-Faithful Consolidation Map v0.1

Anthony Vito Coppa  
27 August 2026

### Purpose

This is a migration map, not a new theorem paper.

It identifies the exact algebraic burdens already proved across the minimum-root family, resolves duplicated or superseded formulations, preserves the strict scope walls, and assigns each surviving result one final place in *EVERYTHING*.

The consolidation rule remains:

> Source theorem → exact surviving statement → scope lock → dependency position → one final location.

No unpublished project paper needs to appear as evidentiary authority in the final bibliography. If a result load-bears in *EVERYTHING*, the theorem and sufficient proof migrate into the keystone or its appendix. Earlier project manuscripts remain provenance and verification records.

---

# I. Governing source order

The minimum-root family should be read in this order.

1. **Selection jurisdiction in EVERYTHING v0.8–v0.10 / Dihedral Phase Constraint canonical edition**  
   Owns the precise meaning of *minimum persistent transport*: the declared class \(\mathcal D_{\mathrm{tr}}\), the five selection duties, trace minimization, coordinate-exchange orbit, and proof that the selected representative is
   \[
   Q=\begin{pmatrix}1&1\\1&0\end{pmatrix}.
   \]

2. **Minimum Root Algebra v2**  
   Owns the compact computational kernel:
   \[
   Q,\quad C_1,\quad \Omega=-C_1,\quad G=[C_1,Q],
   \]
   the basis \((I,Q,\Omega,G)\), full \(M_2(\mathbb R)\) closure, unique normal form, multiplication table, golden eigenframe, finite \(D_4\), and projective \(D_\infty\).

3. **A Complete \(2\times2\) Operator Algebra**  
   Owns the expanded proof archive: exact finite word reduction, coordinate product law, spectral/null factorization, Clifford realization, exact four-phase quotient, hyperbolic glide, unattained projective limit, bounded normalized recurrence, and strict export boundary.

4. **Closed / Solved Results Registers and exact verification scripts**  
   Own theorem IDs, hypotheses, result status, break conditions, and regression receipts. They are verification artifacts, not bibliographic proof authorities.

5. **Minimum Endurance Delta / later synthesis papers**  
   Use only where they contain a unique proof or type clarification not already owned above. They are not allowed to enlarge the root algebra by importing later physical, memory, combinatorial, or semantic structures.

---

# II. Two different meanings of “minimum”

This distinction must survive the rewrite.

## A. Generator minimum

For the full unital real algebra \(M_2(\mathbb R)\), no single real matrix can generate the algebra.

For any \(A\in M_2(\mathbb R)\), Cayley–Hamilton gives

\[
\mathbb R[A]\subseteq \operatorname{span}_{\mathbb R}\{I,A\},
\]

so \(\dim \mathbb R[A]\le2\), and \(\mathbb R[A]\) is commutative. Therefore one generator cannot equal the four-dimensional noncommutative algebra \(M_2(\mathbb R)\).

The pair \((Q,C_1)\) generates all of \(M_2(\mathbb R)\). Hence:

\[
\boxed{\text{two generators are minimal by cardinality for }M_2(\mathbb R).}
\]

This claim is unconditional inside ordinary real \(2\times2\) matrix algebra.

## B. Selected-transporter minimum

The displayed \(Q\) is not claimed to be the universal “smallest matrix.”

It is selected inside the declared class

\[
\mathcal D_{\mathrm{tr}}
=
\left\{
S=\begin{pmatrix}a&b\\b&c\end{pmatrix}:
a,b,c\in\mathbb N_0,\;
\det S=-1,\;
[S]\in PGL_2(\mathbb R)\text{ has infinite order}
\right\}.
\]

The five predicates have separate duties:

1. **Symmetry** — supplies a real orthogonal eigenframe and supports the symmetric commutator-null construction.
2. **Integrality** — supplies exact discrete recurrence data and makes trace minimization well ordered.
3. **Entrywise nonnegativity** — fixes the declared forward ordered cone without coordinate sign cancellation.
4. **Determinant \(-1\)** — normalizes one-step reversal of the alternating and commutator forms, with two-step restoration.
5. **Infinite projective order** — distinguishes persistent advance from finite oscillation.

Order the class by

\[
\mu(S)=\operatorname{tr}S.
\]

Then:

\[
\boxed{
\min_{S\in\mathcal D_{\mathrm{tr}}}\mu(S)=1.
}
\]

The minimizing coordinate-exchange orbit is

\[
\left\{
\begin{pmatrix}1&1\\1&0\end{pmatrix},
\begin{pmatrix}0&1\\1&1\end{pmatrix}
\right\}
=
\{Q,PQP\},
\]

where

\[
P=\begin{pmatrix}0&1\\1&0\end{pmatrix}.
\]

A fixed ordered chart selects

\[
\boxed{
Q=\begin{pmatrix}1&1\\1&0\end{pmatrix}.
}
\]

**Scope lock:** this closes *minimum* only in \(\mathcal D_{\mathrm{tr}}\). Changing the selection predicates defines another problem.

---

# III. Uniform reversal before selecting \(Q\)

The reversal property is not unique to the golden member and therefore cannot itself select \(Q\).

For any symmetric real \(2\times2\) matrix \(S\), define

\[
G_S=[S,\Omega],
\qquad
\Omega=
\begin{pmatrix}0&1\\-1&0\end{pmatrix}.
\]

Then \(G_S\) is symmetric, and every real \(2\times2\) matrix satisfies

\[
S^{\mathsf T}\Omega S=(\det S)\Omega.
\]

For symmetric \(S\),

\[
S^{\mathsf T}G_S S=(\det S)G_S.
\]

Therefore every \(S\in\mathcal D_{\mathrm{tr}}\) obeys

\[
S^{\mathsf T}\Omega S=-\Omega,
\qquad
S^{\mathsf T}G_S S=-G_S,
\]

and hence

\[
(S^2)^{\mathsf T}\Omega S^2=\Omega,
\qquad
(S^2)^{\mathsf T}G_S S^2=G_S.
\]

**Final burden:** one step reverses the two signed forms; two steps restore them.

**Selection lock:** reversal/restoration is a class property. It does not independently prove that \(Q\) is the selected member.

---

# IV. Primitive root data after selection

Fix

\[
Q=
\begin{pmatrix}
1&1\\
1&0
\end{pmatrix},
\qquad
C_1=
\begin{pmatrix}
0&-1\\
1&0
\end{pmatrix},
\qquad
\Omega=-C_1=
\begin{pmatrix}
0&1\\
-1&0
\end{pmatrix}.
\]

Freeze the commutator convention

\[
[A,B]=AB-BA.
\]

Then

\[
G=[C_1,Q]
=
Q\Omega-\Omega Q
=
\begin{pmatrix}
-2&1\\
1&2
\end{pmatrix}.
\]

The immediate identities are

\[
C_1^2=\Omega^2=-I,
\qquad
C_1^4=\Omega^4=I,
\]

\[
Q^2=Q+I,
\qquad
Q^{-1}=Q-I,
\]

\[
G^2=5I.
\]

The selected \(Q\) inherits the uniform reversal certificate:

\[
Q^{\mathsf T}\Omega Q=-\Omega,
\qquad
Q^{\mathsf T}GQ=-G,
\]

while

\[
(Q^2)^{\mathsf T}\Omega Q^2=\Omega,
\qquad
(Q^2)^{\mathsf T}GQ^2=G.
\]

But generally

\[
Q^2v\neq v.
\]

Thus:

\[
\boxed{
\text{form return}\not\Rightarrow\text{state reset}.
}
\]

---

# V. Complete local algebra

The ordered set

\[
\boxed{
\mathcal B=(I,Q,\Omega,G)
}
\]

is a basis of \(M_2(\mathbb R)\).

The coordinate matrix has determinant

\[
\det B=-10\neq0.
\]

Therefore

\[
\boxed{
\operatorname{Alg}_{\mathbb R}(Q,C_1)
=
M_2(\mathbb R).
}
\]

Every

\[
A=
\begin{pmatrix}
a&b\\
c&d
\end{pmatrix}
\in M_2(\mathbb R)
\]

has the unique normal form

\[
A=x_0I+x_1Q+x_2\Omega+x_3G,
\]

where

\[
x_0=\frac{2a+3d-b-c}{5},
\qquad
x_1=\frac{a-d+2b+2c}{5},
\]

\[
x_2=\frac{b-c}{2},
\qquad
x_3=\frac{-2a+2d+b+c}{10}.
\]

**Final burden:** the root is a complete local operator language on the declared real planar carrier.

---

# VI. Exact multiplication and word reduction

The multiplication table on \((I,Q,\Omega,G)\) is finite and closes the algebra.

The load-bearing relations are

\[
Q^2=I+Q,
\qquad
\Omega^2=-I,
\qquad
G^2=5I,
\]

\[
Q\Omega=\frac{\Omega+G}{2},
\qquad
\Omega Q=\frac{\Omega-G}{2},
\]

\[
QG=\frac{G+5\Omega}{2},
\qquad
GQ=\frac{G-5\Omega}{2},
\]

\[
\Omega G=2Q-I,
\qquad
G\Omega=I-2Q.
\]

Every finite word in the alphabet \(\{Q,C_1\}\) evaluates exactly and reduces uniquely to the four-coordinate normal form.

Write

\[
\mathcal W=\{Q,C_1\}^*.
\]

Then the exact pipeline is

\[
\boxed{
\mathcal W
\xrightarrow{\operatorname{Eval}}
M_2(\mathbb Z)
\xrightarrow{\operatorname{NF}}
\mathbb Q^4.
}
\]

This pipeline is algebraic evaluation, not history erasure.

---

# VII. Provenance, value, and receipt remain different

This distinction is already explicit in the source and must be preserved in the keystone:

\[
\boxed{
\text{word provenance}
\neq
\text{operator value}
\neq
\text{normal-form coordinates}
\neq
\text{execution receipt}.
}
\]

Two different words may evaluate to the same matrix.

The unreduced word may therefore be retained as a construction record while the normal form supplies finite exact semantics.

A later execution receipt may certify that a particular word occurred.

**Lock:** normal-form reduction does not rewrite provenance.

This is the exact algebraic precursor of the wider receipt discipline. It is not itself global Memory.

---

# VIII. Fibonacci recurrence is derived, not assumed

The characteristic polynomial of \(Q\) is

\[
\lambda^2-\lambda-1.
\]

Cayley–Hamilton gives

\[
Q^2=Q+I.
\]

Hence, for \(n\ge1\),

\[
\boxed{
Q^n=F_nQ+F_{n-1}I
=
\begin{pmatrix}
F_{n+1}&F_n\\
F_n&F_{n-1}
\end{pmatrix}.
}
\]

The eigenvalues are

\[
\Phi=\frac{1+\sqrt5}{2},
\qquad
\Psi=\frac{1-\sqrt5}{2}=-\Phi^{-1},
\]

with

\[
\Phi+\Psi=1,
\qquad
\Phi\Psi=-1,
\qquad
\Phi-\Psi=\sqrt5.
\]

**Dependency lock:** Fibonacci behavior follows from the selected transporter \(Q\). It is not an independent axiom and does not select \(Q\).

---

# IX. Golden eigenframe and null structure

Define

\[
v_\Phi=
\begin{pmatrix}\Phi\\1\end{pmatrix},
\qquad
v_\Psi=
\begin{pmatrix}\Psi\\1\end{pmatrix}.
\]

Then

\[
Qv_\Phi=\Phi v_\Phi,
\qquad
Qv_\Psi=\Psi v_\Psi.
\]

The symmetric quadratic form

\[
\Delta_G(v)=v^{\mathsf T}Gv
\]

has signature \((1,1)\) and factors as

\[
\Delta_G(x,y)
=
2\left(y-\frac{x}{\Phi}\right)(y+\Phi x).
\]

Its projective null set is exactly the two eigenlines:

\[
\boxed{
\nu_G^{-1}(0)
=
L_\Phi\cup L_\Psi.
}
\]

The oriented alternating-form separation is

\[
\boxed{
v_\Phi^{\mathsf T}\Omega v_\Psi
=
\sqrt5.
}
\]

**Scope lock:** the golden/null correspondence is generated internally by \(Q,\Omega,G\). It is not evidence for gravity, electromagnetism, a measured constant, or another physical mechanism.

---

# X. Fold factorization and normalized mirrors

Define

\[
M_0=Q\Omega.
\]

Then

\[
M_0^2=I,
\qquad
Q=M_0C_1.
\]

In the golden eigenframe, the same operators separate into:

- quarter-turn \(C_1\);
- reflection/fold \(M_0\);
- diagonal transport \(Q\).

The source shorthand

\[
\text{LIFT}=\text{FOLD}\circ\text{ORIENTATION}
\]

is an internal root-role label. It should not be allowed to redefine the later global Offices of Lift/History, Orientation, or Recognition without an explicit adapter.

Normalize

\[
H=\frac{G}{\sqrt5},
\qquad
S=\frac{2Q-I}{\sqrt5}.
\]

Then

\[
H^2=S^2=I,
\]

\[
H^{\mathsf T}H=S^{\mathsf T}S=I,
\qquad
\det H=\det S=-1,
\]

and

\[
H\Omega=-\Omega H,
\qquad
SH=\Omega,
\qquad
HS=-\Omega.
\]

The Clifford presentation is

\[
Cl_{1,1}(\mathbb R)\cong M_2(\mathbb R)
\]

under the displayed normalized generators.

**Editorial lock:** preserve the mathematics; do not import the older mnemonic office names as universal architectural definitions.

---

# XI. Finite and infinite dihedral symmetry

## A. Finite wheel

Since

\[
C_1^4=I,
\qquad
H^2=I,
\qquad
HC_1H=C_1^{-1},
\]

the generated group is

\[
\boxed{
\langle C_1,H\rangle\cong D_4,
}
\]

where \(D_4\) denotes the order-eight symmetry group of the square.

Equivalently, \(\Omega=-C_1\) generates the same four-cycle.

## B. Infinite projective carriage

Let

\[
q=[Q],
\qquad
h=[H]
\]

in \(PGL_2(\mathbb R)\).

Directly,

\[
HQH=-Q^{-1},
\]

so projectively

\[
hqh=q^{-1}.
\]

The eigenvalue ratio of \(Q\) is

\[
\frac{\Phi}{\Psi}=-\Phi^2,
\]

which is not a root of unity. Therefore \(q\) has infinite order.

Hence

\[
\boxed{
\langle q,h\rangle\cong D_\infty.
}
\]

## C. Exact four-phase quotient

The assignment

\[
q\mapsto \Omega,
\qquad
h\mapsto H
\]

gives a surjection

\[
\pi_4:D_\infty\twoheadrightarrow D_4
\]

with kernel

\[
\ker\pi_4=\langle q^4\rangle.
\]

Thus

\[
\boxed{
D_\infty/\langle q^4\rangle\cong D_4.
}
\]

**Lock:** finite visible phase and infinite projective transport are distinct layers related by a declared quotient. The quotient does not supply chronology or occurrence by itself.

---

# XII. Comparison ladder: why the golden member is first

For \(t\in\mathbb N_0\), define

\[
Q_t=
\begin{pmatrix}
t&1\\
1&0
\end{pmatrix},
\qquad
G_t=[Q_t,\Omega]
=
\begin{pmatrix}
-2&t\\
t&2
\end{pmatrix}.
\]

Then

\[
Q_t^2=tQ_t+I,
\qquad
\det Q_t=-1,
\qquad
G_t^2=(t^2+4)I,
\]

and

\[
Q_t^{\mathsf T}\Omega Q_t=-\Omega,
\qquad
Q_t^{\mathsf T}G_tQ_t=-G_t.
\]

The eigenvalues are

\[
\lambda_t=
\frac{t+\sqrt{t^2+4}}{2},
\qquad
-\lambda_t^{-1}.
\]

At \(t=0\),

\[
Q_0=P,
\qquad
Q_0^2=I,
\]

so the projective address oscillates finitely.

For \(t\ge1\), \([Q_t]\) has infinite order, and both \(\lambda_t\) and \(\sqrt{t^2+4}\) increase strictly with \(t\).

Therefore

\[
\boxed{
Q=Q_1,
\qquad
\lambda_1=\Phi,
\qquad
\sqrt{1^2+4}=\sqrt5
}
\]

is the first nonperiodic member and the least positive unbounded transport in the displayed ladder.

**Lock:** the ladder illustrates the theorem. The actual minimum claim remains the trace theorem over all of \(\mathcal D_{\mathrm{tr}}\), not merely the \(Q_t\) family.

---

# XIII. Optional exact extensions: keep out of the root spine unless needed

The expanded operator-algebra paper also proves:

1. a hyperbolic glide-reflection realization of \(Q\);
2. translation length for \(Q^2\);
3. unattained rational convergence to \(\Phi\);
4. explicit spectral projectors \(P_\Phi,P_\Psi\);
5. bounded normalized recurrence
   \[
   \Phi^{-c}Q^c
   =
   P_\Phi+(-\Phi^{-2})^cP_\Psi.
   \]

These are exact and useful.

They are not required to establish:
- selection of \(Q\);
- complete local algebra;
- unique normal form;
- golden/null structure;
- finite/infinite dihedral symmetry.

**Migration ruling:** place them in Appendix A unless a later section specifically needs one.

---

# XIV. Strict scope wall

The root algebra proves no automatic identity with:

- physical gravity;
- spacetime curvature;
- Maxwell propagation;
- gauge curvature;
- spin;
- atomic structure;
- material dynamics;
- biological memory;
- semantic meaning;
- the 137-address register;
- the independent eight-state carrier;
- the twenty-eight seam construction.

The source explicitly keeps these outside the theorem.

In particular:

\[
\boxed{
\text{root matrix}
\neq
\text{physical field}
\neq
\text{reader}
\neq
\text{history}
\neq
\text{meaning}.
}
\]

Any later use requires its own adapter.

---

# XV. Verification receipts

The final keystone should retain proof and verification separately.

## Proof owners to migrate

- trace-one classification in \(\mathcal D_{\mathrm{tr}}\);
- basis determinant \(-10\);
- one-generator minimality via Cayley–Hamilton;
- normal-form solution;
- multiplication table;
- Fibonacci induction;
- golden/null factorization;
- normalized reflection relations;
- finite \(D_4\) proof;
- projective \(D_\infty\) proof;
- four-phase quotient kernel.

## Regression receipts to retain separately

Existing exact scripts check, among other items:

\[
C_1^2=-I,\quad
C_1^4=I,\quad
\Omega^2=-I,\quad
Q^2=Q+I,\quad
Q^{-1}=Q-I,
\]

\[
G=[C_1,Q],\quad
G^2=5I,
\]

Fibonacci powers through finite depth, basis determinant, symbolic normal-form extraction, multiplication-table identities, spectral/null identities, reflection identities, and finite word reduction through a declared depth.

**Lock:** regression is evidence that displayed formulas have not drifted. Universal proofs remain proofs.

---

# XVI. Redundancies resolved

### Minimum Root Algebra vs A Complete \(2\times2\) Operator Algebra

No conflict.

- *Minimum Root Algebra v2* is the preferred compact migration source.
- *A Complete \(2\times2\) Operator Algebra* is the expanded proof/archive source.

The final keystone should own one theorem chain, not cite both as if they were independent authorities.

### Minimum Endurance Delta

The algebraic material is largely subsumed by the root theorem chain.

Retain only unique later burdens—Noether, physical realizations, finite relational carrier, etc.—in their proper later sections. Do not let the broad theorem tuple inflate the algebraic root.

### Dihedral Phase Constraint

Its abstract dihedral theorem and SU(2) central-square theorem are distinct from the planar root algebra.

For the present root section, migrate only:
- the declared \(Q\)-selection theorem if this is the cleanest proof copy;
- the finite/infinite dihedral relation where it duplicates root algebra only once.

The SU(2) central lift belongs to the next **Turn / Mirror / Central Lift** family.

### Old mnemonic role labels

Names such as ORIENTATION, FOLD, LIFT, RECOGNITION, MIRROR inside root-algebra papers are useful local labels.

They do **not** automatically fix the final global Office taxonomy.

Carry the exact matrix duties first; attach global Office names only where the Office audit independently licenses them.

### \(G=[Q,\Omega]\) versus \(G=[C_1,Q]\)

With \(C_1=-\Omega\) and \(Q^{\mathsf T}=Q\),

\[
[C_1,Q]
=
Q\Omega-\Omega Q.
\]

These are the same displayed matrix under the frozen commutator convention. Use one convention consistently in the keystone and state the equivalence once.

---

# XVII. Final dependency order for the algebra section

\[
\boxed{
\begin{array}{c}
\text{declare }\mathcal D_{\mathrm{tr}}
\\[2mm]\downarrow\\
\text{prove class-wide reversal/restoration}
\\[2mm]\downarrow\\
\text{minimize trace and select }Q
\\[2mm]\downarrow\\
C_1,\Omega
\\[2mm]\downarrow\\
G=[C_1,Q]
\\[2mm]\downarrow\\
\{I,Q,\Omega,G\}=M_2(\mathbb R)
\\[2mm]\downarrow\\
\text{unique normal form + exact word reduction}
\\[2mm]\downarrow\\
Q^n=F_nQ+F_{n-1}I
\\[2mm]\downarrow\\
\Phi,\Psi,\sqrt5
\\[2mm]\downarrow\\
\text{golden eigenlines = }G\text{-null lines}
\\[2mm]\downarrow\\
H=G/\sqrt5
\\[2mm]\downarrow\\
D_4\quad\text{and}\quad D_\infty
\\[2mm]\downarrow\\
D_\infty/\langle q^4\rangle\cong D_4
\\[2mm]\downarrow\\
\text{retain word/value/receipt distinction}
\end{array}
}
\]

This is the complete minimum-root algebraic spine needed by the keystone.

---

# XVIII. Migration ruling

**CUT: CLOSED FOR CONSOLIDATION.**

The minimum-root family requires no new algebraic foundation.

The final *EVERYTHING* section should directly own:
- the selection jurisdiction;
- the minimum-\(Q\) theorem;
- the root definitions;
- the complete \(M_2(\mathbb R)\) theorem;
- normal form / finite reduction;
- Fibonacci recurrence;
- golden/null theorem;
- finite and infinite dihedral theorems;
- the word/value/receipt firewall.

Extended hyperbolic, Clifford, normalized-limit, and implementation details may move to Appendix A or the verification register.

The next source family is:

\[
\boxed{
\text{TURN / MIRROR / CENTRAL LIFT}
}
\]

namely:
- abstract dihedral inversion;
- continuous phase;
- System \(\Phi\);
- the \(SU(2)\to SO(3)\) central-square theorem;
- projected closure vs lifted residue;
- the \(i\)-Fold compatible read;
- and the exact boundary between lift and history.
