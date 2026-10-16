# TURN, MIRROR, AND CENTRAL LIFT
## Source-Faithful Consolidation Map v0.1

Anthony Vito Coppa  
27 August 2026

### Purpose

This is a migration map, not a new theorem paper.

It consolidates the already-proved turn / mirror / central-lift family into one dependency-ordered chain for *EVERYTHING*. It preserves exact carrier distinctions among:

- abstract inversion;
- continuous phase;
- planar mirror;
- compatible quarter-turn;
- \(SU(2)\) turning;
- \(SO(3)\) projection;
- central lift residue;
- representation difference;
- append-only occurrence receipt.

The governing rule is:

> Do not identify two return levels merely because they report the same endpoint.

No unpublished project paper needs to appear as an evidentiary authority in the final bibliography. The final keystone must own the theorem statements and sufficient proofs it uses.

---

# I. Governing source order

Read the family in this order.

1. **The Dihedral Phase Constraint**  
   Owns the abstract inversion grammar
   \[
   \Pi^2=e,\qquad \Pi F\Pi=F^{-1},
   \]
   its normal form, finite/infinite dihedral cases, the phase-circle realization, and the dependency wall separating inversion from later carrier selection.

2. **System \(\Phi\): Turning Symmetry in \(SU(2)\) Forces a Central Square**  
   Owns the independent central-square theorem
   \[
   g\Phi(t)g^{-1}=\Phi(-t)\Longrightarrow g^2=-I=\Phi(\pi),
   \]
   the self-centralizing circle argument, the non-split normalizer extension, and the projection
   \[
   p(g)^2=I
   \]
   under \(SU(2)\to SO(3)\).

3. **The \(i\) Fold**  
   Owns the null-seam multiplier, the distinction between golden product and golden ratio, form return without state return, and the compatible-complex-structure positivity
   \[
   g_i(u,v)=\omega(u,iv).
   \]

4. **Central Lift, Representation Difference, and Retained Occurrence / Memory Return**  
   Owns the typed hierarchy:
   \[
   \text{reader return}\;|\;\text{lifted endpoint}\;|\;\text{represented difference}\;|\;\text{occurrence receipt},
   \]
   together with the nonlinear representation-difference law, central monodromy, split append, and the central closure triple.

5. **Closed / Solved Results Registers and exact checkers**  
   Own theorem IDs, status, hypotheses, and regression receipts. They are verification artifacts, not bibliographic authorities.

---

# II. Abstract inversion grammar

Let \(G\) be a group. Let \(F\in G\) be invertible and \(\Pi\in G\) an involution:

\[
\Pi^2=e.
\]

The **dihedral phase constraint** is

\[
\boxed{
\Pi F\Pi=F^{-1}.
}
\]

Then, for every \(n\in\mathbb Z\),

\[
\Pi F^n\Pi=F^{-n}.
\]

Every word in \(F,\Pi\) reduces to one of the two forms

\[
F^n,\qquad \Pi F^n.
\]

If \(F\) has infinite order,

\[
\boxed{\langle F,\Pi\rangle\cong D_\infty.}
\]

If \(F\) has finite order \(N\ge3\) and \(\Pi\notin\langle F\rangle\),

\[
\boxed{\langle F,\Pi\rangle\cong D_N}
\]

with \(|D_N|=2N\).

**Scope lock:** this is an inversion grammar. It does not select \(Q\), define a physical rotation, provide chronology, or supply a receipt.

---

# III. Continuous phase

Let \(A\) generate a one-parameter group

\[
F(t)=e^{tA}.
\]

For an involution \(\Pi\),

\[
\Pi F(t)\Pi=F(-t)
\]

is equivalent to

\[
\Pi A\Pi=-A.
\]

For the normalized phase circle, let \(J^2=-I\) and define

\[
U(t)=e^{tJ}
=
\cos t\,I+\sin t\,J.
\]

Then

\[
U(\pi)=-I,
\qquad
U(2\pi)=I.
\]

The phase circle therefore contains a distinguished nonidentity central half-turn at \(\pi\) and full identity return at \(2\pi\).

**Lock:** \(t\) is a group parameter. It is not automatically metric, thermodynamic, biological, or experienced time.

---

# IV. Planar mirror versus lifted turn

The root algebra already supplies

\[
C_1^4=I,
\qquad
H^2=I,
\qquad
HC_1H=C_1^{-1}.
\]

Hence

\[
\langle C_1,H\rangle\cong D_4.
\]

This is the involutive planar mirror case.

The \(SU(2)\) turning theorem is stricter.

It must not be replaced by the planar relation merely because both enact inversion.

---

# V. System \(\Phi\): the forced central square

Let

\[
T=\Phi(\mathbb R)\subset SU(2),
\qquad
\Phi(t)=e^{tH_0},
\qquad
H_0^2=-I.
\]

Assume \(T\) is nontrivial and

\[
g\Phi(t)g^{-1}=\Phi(-t)
\qquad
\forall t\in\mathbb R.
\]

Equivalently,

\[
gH_0g^{-1}=-H_0.
\]

The proof chain is:

1. \(g\) normalizes \(T\).
2. Applying inversion twice gives
   \[
   g^2\in C_{SU(2)}(T).
   \]
3. A nontrivial circle in \(SU(2)\) is self-centralizing:
   \[
   C_{SU(2)}(T)=T.
   \]
4. Since \(g\) inverts \(T\) but commutes with \(g^2\),
   \[
   g^2=(g^2)^{-1},
   \]
   so
   \[
   g^2\in\{\pm I\}.
   \]
5. \(SU(2)\) has no noncentral involution. If \(g^2=I\), then \(g=\pm I\), which cannot invert a nontrivial circle.
6. Therefore
   \[
   \boxed{
   g^2=-I.
   }
   \]

Because

\[
\Phi(\pi)=-I,
\]

the theorem is

\[
\boxed{
g\Phi(t)g^{-1}=\Phi(-t)
\Longrightarrow
g^2=-I=\Phi(\pi),
\qquad
g^4=I.
}
\]

This is the central hinge.

---

# VI. The normalizer is non-split

After conjugating the circle to the diagonal torus \(T_0\), let

\[
j=
\begin{pmatrix}
0&1\\
-1&0
\end{pmatrix}.
\]

Then

\[
j^2=-I,
\qquad
jtj^{-1}=t^{-1}
\quad (t\in T_0).
\]

The normalizer is

\[
N_{SU(2)}(T_0)
=
T_0\sqcup jT_0.
\]

Every element outside \(T_0\) squares to \(-I\).

Hence

\[
1\to U(1)\to N_{SU(2)}(T)\to\mathbb Z_2\to1
\]

does **not** split.

In the standard convention this subgroup is denoted

\[
\operatorname{Pin}(2).
\]

**Correction lock:** retain the non-split extension. Do not revert to an earlier split-semidirct-product description.

---

# VII. Projection closes before the lift

Let

\[
p:SU(2)\to SO(3)
\]

be the standard double cover with kernel \(\{\pm I\}\).

Since

\[
g^2=-I,
\]

one has

\[
p(g)^2=p(-I)=I.
\]

Thus:

\[
\boxed{
\text{upstairs: }g\text{ has order }4,
\qquad
\text{downstairs: }p(g)\text{ has order }2.
}
\]

The projected operation is an involution while the lift retains the nontrivial central square.

This is not a contradiction. It is a quotient.

---

# VIII. Central monodromy of rotation loops

For a based loop

\[
\gamma:[0,1]\to SO(3)
\]

and a chosen lift \(\widetilde\gamma\) beginning at \(\widetilde g_0\), define

\[
\varepsilon_{\mathrm{cen}}(\gamma)\in\{\pm I\}
\]

by

\[
\widetilde\gamma(1)
=
\varepsilon_{\mathrm{cen}}(\gamma)\widetilde g_0.
\]

Then:

- the class is independent of the chosen initial sheet;
- it is invariant under based homotopy;
- it is multiplicative under loop concatenation;

and it realizes

\[
\boxed{
\pi_1(SO(3))\cong\{\pm I\}\cong\mathbb Z/2\mathbb Z.
}
\]

For the standard axial loops,

\[
\varepsilon_{\mathrm{cen}}(\gamma_{2\pi})=-I,
\qquad
\varepsilon_{\mathrm{cen}}(\gamma_{4\pi})=I.
\]

**Lock:** the central endpoint is a two-valued reduced read. It is not a complete traversal history.

---

# IX. Representation difference

Let

\[
\rho:G\to GL(W).
\]

Define

\[
\boxed{
D_\rho(g)=\rho(g)-I_W.
}
\]

Then

\[
D_\rho(gh)
=
D_\rho(g)+D_\rho(h)+D_\rho(g)D_\rho(h).
\]

Define

\[
A\boxplus B:=A+B+AB.
\]

Then

\[
D_\rho(gh)=D_\rho(g)\boxplus D_\rho(h),
\]

and

\[
I+(A\boxplus B)=(I+A)(I+B).
\]

Thus \(\boxplus\) transports the group law into represented-difference space.

Its zero set is exact:

\[
\boxed{
D_\rho(g)=0
\Longleftrightarrow
g\in\ker\rho.
}
\]

Therefore a zero represented-difference read means that the declared representation is silent on \(g\). It means \(g=e\) only when \(\rho\) is faithful.

**Lock:** zero read \(\neq\) no event.

---

# X. Reader return does not erase the lift

Let

\[
r:X\to Y
\]

be a declared reader and \(x:[0,1]\to X\) a path.

An \(r\)-return means

\[
r(x(1))=r(x(0)).
\]

This equality lives in \(Y\).

It does not imply

\[
x(1)=x(0).
\]

For a covering return datum, reader closure is compatible with all of:

\[
\widetilde\gamma(1)\neq\widetilde\gamma(0),
\]

\[
D_\rho(\varepsilon)\neq0,
\]

\[
o_{n+1}\neq o_n,
\]

\[
R_{n+1}\neq R_n.
\]

None of these implications is automatic because they occupy distinct carriers.

This gives the exact hierarchy:

\[
\boxed{
\text{reader return}
\neq
\text{lifted endpoint}
\neq
\text{represented difference}
\neq
\text{occurrence address}
\neq
\text{receipt}.
}
\]

---

# XI. Lift placement: covering torus versus physical quotient

Let

\[
U(1)_{\mathrm{top}}\subset SU(2)
\]

be the maximal torus and

\[
q:U(1)_{\mathrm{top}}\to SO(2)_{\mathrm{phys}},
\qquad
q(z)=z^2.
\]

For a real two-plane \(W\) with \(C_1^2=-I\), define

\[
\rho_W(e^{i\alpha})=e^{\alpha C_1}.
\]

Two results must stay separate.

## Lower-quotient obstruction

If the plane action is first placed on \(SO(2)_{\mathrm{phys}}\) and pulled back along \(q\), there is no nonzero \(U(1)_{\mathrm{top}}\)-equivariant linear map from the defining spinor representation to the complexified plane.

The obstruction is the central sign: \(-1\in\ker q\) is invisible downstairs but acts as \(-I\) on the defining spinor.

## Covering-torus equivalence

If the phase-plane action is placed directly on \(U(1)_{\mathrm{top}}\), then after choosing the axis and compatible weight bases, the complexified plane has the same \(\pm1\) weights as the restricted defining spinor.

Hence an axis-relative equivariant isomorphism exists.

**Lock:** this is an equivalence on the chosen covering torus. It is not a canonical global \(SU(2)\)-module identity.

---

# XII. The \(i\) Fold

On the real root plane, let

\[
\omega(u,v)=u^{\mathsf T}\Omega v,
\qquad
i=-\Omega.
\]

Then

\[
i^2=-I.
\]

Pairing the alternating form with the quarter-turn gives

\[
\boxed{
g_i(u,v)=\omega(u,iv).
}
\]

Because

\[
\Omega(-\Omega)=I,
\]

one gets

\[
g_i(u,v)=u^{\mathsf T}v,
\qquad
g_i(u,u)=\|u\|^2\ge0.
\]

The \(i\)-Fold is therefore the compatible-complex-structure passage

\[
(\omega,i)\mapsto g_i
\]

when \(i^2=-I\) and the resulting \(g_i\) is positive definite.

This has a Hilbert-space extension: on \(H\oplus H\),

\[
J(x,p)=(-p,x),
\]

\[
\Omega((x,p),(y,q))
=
\langle x,q\rangle-\langle p,y\rangle,
\]

so

\[
\Omega(u,Ju)
=
\|x\|^2+\|p\|^2\ge0.
\]

**Namespace lock:** the real operator \(i=-\Omega\) is a compatible quarter-turn on the real carrier. It is not to be silently identified with every occurrence of the ordinary complex scalar \(\mathbf i\) used elsewhere.

---

# XIII. Product and ratio have different offices

The \(i\)-Fold paper isolates an important distinction.

The golden product

\[
\Phi\Psi=-1
\]

governs congruence reversal of the split symmetric form.

The golden ratio of eigenvalues

\[
\frac{\Phi}{\Psi}=-\Phi^2
\]

governs projective displacement and infinite projective order.

Therefore:

\[
\boxed{
\text{product controls pullback sign;}
\qquad
\text{ratio controls address scale.}
}
\]

Conflating them collapses two different operations.

This distinction should remain explicit in the keystone.

---

# XIV. Form return without state return

For the root carrier,

\[
Q^{\mathsf T}\Omega Q=-\Omega,
\qquad
Q^{\mathsf T}GQ=-G.
\]

Therefore two steps restore both forms:

\[
(Q^2)^*\omega=\omega,
\qquad
(Q^2)^*g_Q=g_Q.
\]

But on the golden eigenvectors,

\[
Q^2v_\Phi=\Phi^2v_\Phi\neq v_\Phi,
\]

\[
Q^2v_\Psi=\Psi^2v_\Psi\neq v_\Psi.
\]

Hence

\[
\boxed{
\text{form return}\not\Rightarrow\text{state return}.
}
\]

This is the planar algebraic form of the same distinction that the \(SU(2)\to SO(3)\) cover expresses as projected return versus lifted residue.

The mechanisms differ; the audit duty is shared.

---

# XV. Split append and occurrence

Let \(R\) be a receipt type and

\[
\operatorname{snoc}(R_n,r)
\]

append \(r\) to a finite archive.

Then

\[
\operatorname{dropLast}(\operatorname{snoc}(R_n,r))
=
R_n,
\]

\[
\operatorname{last}(\operatorname{snoc}(R_n,r))
=
r.
\]

Thus append is split in the archive argument.

The previous archive and the new receipt are both recoverable.

Repeated equal-valued receipts remain distinct by position and length.

**Critical lock:**

\[
\boxed{
\text{Lift is not History.}
}
\]

A lift may retain sheet, parity, or endpoint defect.

A receipt may retain a path, selected lift, witnesses, occurrence address, and whatever further distinctions the claim promises.

The central element \(-I\) retains at most the central class carried by the chosen representation. It is not a complete path receipt.

---

# XVI. Central closure triple

For a double cover with nontrivial deck element \(z\) satisfying

\[
\rho(z)=-I_W,
\]

define the two exact operator reads

\[
C_\rho(z)=\rho(z)+I_W,
\]

\[
D_\rho(z)=\rho(z)-I_W.
\]

Then

\[
C_\rho(z)=0,
\qquad
D_\rho(z)=-2I_W\neq0.
\]

With an appended receipt,

\[
R_{n+1}=\operatorname{snoc}(R_n,r_{n+1}),
\qquad
R_{n+1}\neq R_n.
\]

Therefore

\[
\boxed{
\left(
C_\rho(z),
D_\rho(z),
R_{n+1}
\right)
=
\left(
0,
-2I_W,
\operatorname{snoc}(R_n,r_{n+1})
\right).
}
\]

These entries occupy

\[
\operatorname{End}(W)
\times
\operatorname{End}(W)
\times
\operatorname{Ledger}(R).
\]

This is the exact central closure triple:

\[
\boxed{
\text{closure can be zero}
\quad|\quad
\text{represented difference nonzero}
\quad|\quad
\text{occurrence retained}.
}
\]

There is no contradiction because these are different reads in different carriers.

---

# XVII. Double return: endpoint and difference can both close while history remains

For two concatenated \(2\pi\) loops in the defining spinor representation,

\[
(-I)(-I)=I,
\]

and under the represented-difference law,

\[
(-2I)\boxplus(-2I)
=
-2I-2I+4I
=
0.
\]

Thus after a \(4\pi\) traversal:

- the central endpoint is \(+I\);
- represented difference is \(0\);
- the lossless receipt still distinguishes the traversed loop from the constant path.

So the hierarchy is:

\[
\boxed{
\text{projected endpoint}
<
\text{central endpoint class}
<
\text{represented difference}
<
\text{lossless occurrence receipt}
}
\]

only in **retained resolution**, not in numerical magnitude.

A later reader may preserve more of the traversal without changing the endpoint reported by an earlier reader.

---

# XVIII. What the \(i\)-Fold does not contribute to this spine

The \(i\)-Fold paper also contains a correct real-odd Fourier positivity result:

\[
\widehat f(\gamma)\in i\mathbb R
\quad\Longrightarrow\quad
-\widehat f(\gamma)^2
=
|\widehat f(\gamma)|^2
\ge0
\]

for real odd \(f\) and real spectral \(\gamma\).

It explicitly leaves open:

- a global arithmetic intertwiner into the \(i\)-Fold metric;
- universal Weil positivity;
- the Riemann Hypothesis.

These analytic results are not needed for the Turn / Mirror / Central Lift spine.

**Migration ruling:** move them to an analytic-boundary appendix or library branch. Do not make them load-bearing here.

---

# XIX. Redundancies resolved

## Dihedral Phase Constraint vs Minimum Root Algebra

The root algebra already carries the concrete planar \(D_4/D_\infty\) realization.

The Dihedral paper owns the **abstract inversion theorem**. State that once, then instantiate it where needed.

## Dihedral Phase Constraint vs System \(\Phi\)

They are not duplicates.

- Dihedral: involutive mirror
  \[
  \Pi^2=e,\quad \Pi F\Pi=F^{-1}.
  \]
- System \(\Phi\): lifted turning element in \(SU(2)\)
  \[
  g^2=-I.
  \]

The entire point is that the lifted turn is **not** an involution upstairs even though its projection is one downstairs.

## System \(\Phi\) vs Central Lift paper

System \(\Phi\) proves the forced square.

Central Lift/Memory Return explains what may and may not be inferred from that square:
- projection;
- central monodromy;
- representation read;
- silent locus;
- receipt.

The latter should not be allowed to obscure the independent proof of the former.

## Central Lift vs Memory Return

These are essentially two presentations of the same return-typing family.

Use the most mature theorem statements and keep one final proof chain.

Do not cite both as independent authorities.

## \(i\)-Fold vs root algebra

The root algebra already proves the specific \(Q\)-reversal identities.

The \(i\)-Fold contributes two genuinely distinct results:
1. the general null-seam multiplier
   \[
   A^*B=(\det A)B;
   \]
2. compatible-complex-structure positivity
   \[
   g_i(u,v)=\omega(u,iv).
   \]

Carry those; do not duplicate the whole root proof.

---

# XX. Final dependency order for this section

\[
\boxed{
\begin{array}{c}
\Pi F\Pi=F^{-1}
\\[2mm]\downarrow\\
\text{finite/infinite dihedral normal form}
\\[2mm]\downarrow\\
U(t)=e^{tJ},\quad J^2=-I
\\[2mm]\downarrow\\
U(\pi)=-I,\quad U(2\pi)=I
\\[2mm]\downarrow\\
gU(t)g^{-1}=U(-t)
\\[2mm]\downarrow\\
g^2=-I,\quad g^4=I
\\[2mm]\downarrow\\
SU(2)\to SO(3)
\\[2mm]\downarrow\\
\text{projected involution / central lift residue}
\\[2mm]\downarrow\\
\varepsilon_{\mathrm{cen}}(\gamma)
\\[2mm]\downarrow\\
D_\rho(g)=\rho(g)-I
\\[2mm]\downarrow\\
D_\rho(gh)=D_\rho(g)\boxplus D_\rho(h)
\\[2mm]\downarrow\\
D_\rho(g)=0\iff g\in\ker\rho
\\[2mm]\downarrow\\
\text{split append / receipt}
\\[2mm]\downarrow\\
\text{central closure triple}
\\[2mm]\downarrow\\
\text{double return with retained traversal}
\end{array}
}
\]

Alongside it, on the real planar carrier:

\[
\boxed{
\omega
\;\xrightarrow{i^2=-I}\;
g_i(u,v)=\omega(u,iv)
}
\]

supplies the compatible positive read.

---

# XXI. Migration ruling

**CUT: CLOSED FOR CONSOLIDATION.**

The final *EVERYTHING* section should directly own:

- abstract inversion theorem;
- continuous phase normalization;
- the central-square theorem;
- non-split normalizer result;
- \(SU(2)\to SO(3)\) projection distinction;
- central monodromy;
- representation-difference calculus;
- silent-locus theorem;
- \(i\)-Fold compatible metric;
- product-versus-ratio distinction;
- form-return/state-return distinction;
- split append;
- central closure triple;
- double-return-with-retained-traversal theorem;
- the hard law:
  \[
  \boxed{\text{Lift is not History.}}
  \]

The next source family is:

\[
\boxed{
\text{MOTION / RETURN / MEMORY / LINEAR INFINITY}
}
\]

namely:
- Motion and Difference;
- Memory Return where not already absorbed here;
- Architecture of Silence;
- Linear Infinity;
- axial carriage and corrected forward coordinate;
- quotient return versus noncompact lift;
- harmonic return period;
- Mirror Escapement / Euler Escapement;
- and the exact typed relation among Return, Silence, Memory, and Time.
