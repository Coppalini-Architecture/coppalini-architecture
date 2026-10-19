# Ultraviolet Fixed-Point Closure

## Gaussian Carrier and Minimum TT Reader v0.6

**Date:** 25 September 2026  
**Status:** Gaussian carrier and minimum two-polarization TT reader CLOSED; helicity residue typed; parity-conditioned scalar residue reduced to one finite graph-state overlap  
**Operator record:** Anthony Vito Coppa

### Claim marks

- **[SRC-HAN]** imported from Han, arXiv:2602.18665.
- **[SRC-CONT]** imported from *Contact Recognition Continuum*, ed. 1.15.
- **[SRC-CLOS]** imported from *Continuum Closure in Covariant LQG*, 15 September 2026.
- **[SRC-PROP]** imported from the standard Lorentzian EPRL boundary-metric two-point prescription.
- **[SRC-MAP]** imported from *Mirror Recognition Single Composition Map — Unitary Phase and TT Fold*, v0.2.
- **[DEF]** exact local definition.
- **[DER-HAN]** derived directly from Han's displayed Hessian.
- **[THM]** follows from the displayed hypotheses.
- **[READ]** an already-present object read in a declared chart.
- **[IF-REF]** conditional on the displayed regular-refinement symbol.
- **[IF-ROT]** conditional on rotational covariance about \(\widehat p\).
- **[IF-PAR]** conditional on mirror/parity invariance of the selected packet.
- **[OPEN-OVERLAP]** one finite physical matrix element remains to be evaluated.

---

## 0. Return

The source amplitude carries the first boundary response. Han also supplies its quadratic bulk fluctuation matrix. The universal first-order covariance is therefore readable by matrix inversion.

The calculation separates into two exact parts:

\[
\boxed{
\text{bulk carrier}
\quad\big|\quad
\text{boundary spin-two overlap}.
}
\]

The bulk carrier is calculated below. The remaining overlap is a finite read of the existing boundary blocks, sector coefficients, boundary state, and physical quotient.

---

## 1. Fixed point and first difference [SRC-HAN]

For uniformly large internal cutoff and small condensation spin,

\[
\boxed{
\mathscr A(A_{\rm cut})
=
\sum_{\boldsymbol\varsigma}
b_{\boldsymbol\varsigma}B_{\boldsymbol\varsigma}
\bigl[1+O(A_{\rm cut}^{-1})\bigr].
}
\]

Write the leading cutoff-chart family as

\[
\mathscr A_{*,A}(A_{\rm cut})
:=
\sum_{\boldsymbol\varsigma}
b_{\boldsymbol\varsigma}(A_{\rm cut})
B_{\boldsymbol\varsigma}.
\]

The leading bulk is topological. The first propagating slot is the order \(A_{\rm cut}^{-1}\) fluctuation about the critical manifold.

Contact records that slot in the neutral chart

\[
\boxed{
\mathcal A(u)
=
\mathcal A_*
+uZ_1^{\rm UV}
+O(u^2).
}
\]

The cutoff remainder family can be read without assuming a coefficient limit:

\[
\boxed{
R_{1,A}(A_{\rm cut})
:=
A_{\rm cut}
\bigl[
\mathscr A(A_{\rm cut})
-\mathscr A_{*,A}(A_{\rm cut})
\bigr].
}
\]

Han proves the required relative \(O(A_{\rm cut}^{-1})\) bound. His leading coefficient contains bounded periodic cutoff dependence, so a constant limit for \(R_{1,A}\), after the declared leading normalization, requires an additional ray, phase, averaging, or matching prescription. The neutral parameter \(u\) remains distinct from \(A_{\rm cut}^{-1}\), and \(\mathscr A_{*,A}\) is not silently substituted for the neutral \(\mathcal A_*\).

---

## 2. Boundary read and physical quotient [READ, THM]

For boundary test states \(\phi_{\rm out},\phi_{\rm in}\in\mathcal E_\Sigma\), the first-order boundary kernel is

\[
K_{1,\Sigma}^{\rm UV}
(\phi_{\rm out},\phi_{\rm in})
:=
\left.
\partial_u
\mathcal A_\Sigma(u)
[\overline{\phi_{\rm out}},\phi_{\rm in}]
\right|_{u=0}.
\]

Its distributional operator-coordinate is the same kernel with one slot held open:

\[
\boxed{
\bigl(\mathcal D_{1,\Sigma}^{\rm UV}\phi_{\rm in}\bigr)
[\overline{\phi_{\rm out}}]
:=
K_{1,\Sigma}^{\rm UV}
(\phi_{\rm out},\phi_{\rm in}),
\qquad
\mathcal D_{1,\Sigma}^{\rm UV}:
\mathcal E_\Sigma\to\mathcal E_\Sigma'.
}
\]

Let \(N_\Sigma:=\ker\eta_\Sigma\). The kernel has a unique physical read on \(\mathcal E_\Sigma/N_\Sigma\) exactly when

\[
\boxed{
K_{1,\Sigma}^{\rm UV}(n,\phi)=0
=
K_{1,\Sigma}^{\rm UV}(\phi,n)
\quad
\text{for every }n\in N_\Sigma,
\ \phi\in\mathcal E_\Sigma.
}
\]

Then

\[
\overline K_{1,\Sigma}^{\rm UV}
([\phi]_{\rm phys},[\psi]_{\rm phys})
:=
K_{1,\Sigma}^{\rm UV}(\phi,\psi).
\]

This quotient rule is closed. It removes null presentation while preserving the carried response.

---

## 3. Han's transverse Hessian [SRC-HAN]

Use Han's simplifying hypotheses for the explicit Hessian block:

\[
A_h=A_{\rm cut},
\qquad
k_0\in2\mathbb Z_{>0},
\qquad
\pi_1(\mathcal K_-)=0,
\qquad
\gamma\text{ small}.
\]

Let \(t_e=t_e^a(-{\rm i}L^a)\) be the gauge-fixed \(\mathrm{SU}(2)\) holonomy fluctuation on an internal edge. Define the face-edge coboundary

\[
\boxed{
(d_1t)_h
:=
\sum_{e\subset\partial h}
s_e(h)t_e.
}
\]

Because \(k_0\) is even, Han's sign factor satisfies \(\varsigma_h^{k_0}=1\). His Hessian quadratic form becomes

\[
\boxed{
t^{\mathsf T}\mathbb H_t t
=
-C_2\sum_h\|(d_1t)_h\|^2,
}
\]

or equivalently

\[
\boxed{
-\mathbb H_t
=
C_2\,d_1^{*}d_1\otimes I_3.
}
\]

Han proves this block nondegenerate after the stated gauge fixing when the interior is simply connected.

---

## 4. Exact normalization [DER-HAN]

Han's coefficient is

\[
C_2
=
\frac{1}{12}
d_{k_0}^{2}
(d_{k_0}-1)(d_{k_0}+1)
C_0^{-1},
\qquad
C_0=d_{k_0}^{2}E_{k_0}.
\]

Therefore

\[
C_2
=
\frac{d_{k_0}^{2}-1}{12E_{k_0}}.
\]

For Han's declared spectrum

\[
E_k=k(k+2),
\qquad
d_k=k+1,
\]

we have

\[
E_k=d_k^2-1,
\]

and hence

\[
\boxed{
C_2=\frac1{12},
\qquad
-\mathbb H_t
=
\frac1{12}
d_1^{*}d_1\otimes I_3.
}
\]

The sign and normalization of this quadratic carrier are fixed.

---

## 5. First covariance and exponent convention [THM]

Han's amplitude is written with exponent \(e^{S}\), not \(e^{{\rm i}S}\),
and satisfies \(\operatorname{Re}S\le0\). On the even-\(k_0\), leading
small-\(\gamma\) transverse \(t\)-block used here, the Hessian is real and
negative. This block is therefore Laplace-type inside Han's complex
stationary-phase calculation.

Write its local large-cutoff expansion as

\[
S_{A}(t)
=
S_{A,*}
-\frac{A_{\rm cut}}2t^{\mathsf T}K_t t
+O\!\left(A_{\rm cut}\lVert t\rVert^3\right),
\qquad
K_t:=-\mathbb H_t>0.
\]

No Feynman factor of \({\rm i}\) is inserted in this convention. A propagator
defined from an \(e^{{\rm i}S}\) convention would require its phase to be
carried separately and is not the covariance defined below.

The connected Gaussian covariance is

\[
\langle tt^{\mathsf T}\rangle_c
=
A_{\rm cut}^{-1}K_t^{-1}
+O(A_{\rm cut}^{-2}).
\]

Thus the first coefficient is

\[
\boxed{
G_{t,1}
:=
\lim_{A_{\rm cut}\to\infty}
A_{\rm cut}
\langle tt^{\mathsf T}\rangle_c
=
12
\bigl(d_1^{*}d_1\bigr)^{-1}
\otimes I_3.
}
\]

This is Han's first propagating Gaussian carrier in common-sense form:

\[
\boxed{
\text{response}
=
12\times
\text{inverse discrete curvature stiffness}.
}
\]

---

## 6. Long-wave read [IF-REF]

Suppose a declared local regular refinement and physical scale map give

\[
\boxed{
\widehat{d_1^{*}d_1}(p)
=
\alpha_{\rm ref}\,p^2P_T(p)
+O(p^4),
\qquad
\alpha_{\rm ref}>0,
}
\]

on the gauge-reduced transverse connection sector. The coefficient \(\alpha_{\rm ref}\) carries the refinement-to-physical-scale normalization; it is not identified with \(A_{\rm cut}^{-1}\) or \(a_{\rm lat}^{2}\).

Then

\[
\boxed{
G_{t,1}(p)
=
\frac{12}{\alpha_{\rm ref}}
\frac{P_T(p)\otimes I_3}{p^2}
+G_{t,\rm regular}(p).
}
\]

Therefore the Han Hessian carries a positive massless transverse **connection** pole.

---

## 7. Boundary metric read [SRC-PROP]

The LQG boundary metric observable is the flux bilinear

\[
q^{ab}(x)
=
\delta^{ij}E_i^a(x)E_j^b(x).
\]

Its connected two-point read is

\[
G^{abcd}(x,y)
=
\langle q^{ab}(x)q^{cd}(y)\rangle
-
\langle q^{ab}(x)\rangle
\langle q^{cd}(y)\rangle.
\]

On a spin-\(j\) boundary representation, the local traceless rank-two operator is

\[
\boxed{
Q_{ab}^{(2)}
:=
\frac12\{L_a,L_b\}
-
\frac13\delta_{ab}j(j+1)I.
}
\]

It is nonzero for every boundary spin \(j\ge1\). Indeed,

\[
Q_{zz}^{(2)}|j,j\rangle
=
\frac{j(2j-1)}3|j,j\rangle
\ne0.
\]

Han's boundary blocks act on spin-network states in \(\mathbf{Cyl}\). Choosing a physical boundary state with at least one relevant link spin \(j\ge1\) therefore supplies a nonzero local spin-two metric read. This boundary-spin condition is distinct from the internal condensation-spin condition \(k_0\in2\mathbb Z_{>0}\).

---

## 8. Physical TT residue [IF-REF, IF-ROT]

Fix \(\widehat p=\widehat z\) for the displayed polarization coordinates and
define

\[
V_{\rm TT}(\widehat p)
:=
\operatorname{span}_{\mathbb R}
\{t_+(\widehat p),t_\times(\widehat p)\}.
\]

Let \(\Pi_{\rm TT}^{(2)}(\widehat p)\) be the orthogonal projection onto this
plane, and let

\[
\mathcal B_2(p):
\text{physical transverse connection fluctuations}
\longrightarrow
V_{\rm TT}(\widehat p)
\]

denote the derivative of the already-declared boundary metric observable inside
the physical boundary functional. It includes the chosen boundary state, the
finite sector coefficients \(b_{\boldsymbol\varsigma}\), and quotient descent.
Assume \(\mathcal B_2(p)\) is continuous at \(p=0\).

The pole part induced by the Gaussian carrier is

\[
\boxed{
P_{1,\rm phys}^{\rm TT}(p)
=
\frac{W_{\rm TT}}{p^2}
+P_{\rm regular}(p),
}
\]

with positive-semidefinite residue

\[
\boxed{
W_{\rm TT}
=
\frac{12}{\alpha_{\rm ref}}
\Pi_{\rm TT}^{(2)}
\mathcal B_2(0)
(P_T\otimes I_3)
\mathcal B_2(0)^{\dagger}
\Pi_{\rm TT}^{(2)}.
}
\]

Import the exact spin-two phase action from [SRC-MAP]:

\[
D_{\rm TT}(\alpha)=U_{\rm ph}(-2\alpha)
=e^{-2\alpha C_{\rm TT}}.
\]

Let \(H_{\rm TT}\) be the represented mirror on this plane, satisfying

\[
H_{\rm TT}^2=I,
\qquad
H_{\rm TT}C_{\rm TT}H_{\rm TT}=-C_{\rm TT}.
\]

On the complexified TT plane define

\[
\Pi_{\pm2}
:=
\frac12
\bigl(I\mp {\rm i}C_{\rm TT}\bigr).
\]

Assume rotational covariance about \(\widehat p\):

\[
\boxed{
D_{\rm TT}(\alpha)
W_{\rm TT}
D_{\rm TT}(\alpha)^\dagger
=
W_{\rm TT}
}
\tag{IF-ROT}
\]

This gives the two-helicity form

\[
\boxed{
W_{\rm TT}
=
Z_+^{-1}\Pi_{+2}
+
Z_-^{-1}\Pi_{-2},
\qquad
Z_\pm^{-1}\ge0.
}
\]

For normalized helicity vectors \(t_\pm\), define the reduced couplings once:

\[
\boxed{
\beta_\pm
:=
\left\|
(P_T\otimes I_3)
\mathcal B_2(0)^\dagger t_\pm
\right\|
\in\mathbb R_{\ge0}.
}
\]

Then

\[
\boxed{
Z_\pm^{-1}
=
\frac{12}{\alpha_{\rm ref}}\beta_\pm^2,
\qquad
Z_\pm^{-1}>0
\iff
\beta_\pm\ne0.
}
\]

Rotational covariance alone permits \(Z_+^{-1}\ne Z_-^{-1}\). If the selected
packet is also invariant under the represented mirror/parity action,

\[
\boxed{
H_{\rm TT}W_{\rm TT}H_{\rm TT}=W_{\rm TT},
}
\tag{IF-PAR}
\]

then \(H_{\rm TT}\Pi_{+2}H_{\rm TT}=\Pi_{-2}\) forces

\[
\beta_+=\beta_-=: \beta_{\rm TT},
\]

and therefore

\[
\boxed{
W_{\rm TT}
=
Z_h^{-1}\Pi_{\rm TT}^{(2)},
\qquad
Z_h^{-1}
=
\frac{12}{\alpha_{\rm ref}}\beta_{\rm TT}^2.
}
\]

---

## 9. The remaining finite read [OPEN-OVERLAP]

The linear-response realization of the selected graph, sector vector, physical
boundary state, quotient, and TT insertions supplies \(\mathcal B_2(0)\). Its
Gram operator then determines the two reduced norms

\[
\boxed{
(\beta_+,\beta_-)
=
\left(
\left\|(P_T\otimes I_3)\mathcal B_2(0)^\dagger t_+\right\|,
\left\|(P_T\otimes I_3)\mathcal B_2(0)^\dagger t_-\right\|
\right).
}
\]

These are linear-response norms. The connected two-point pole carries their
squares, \(12\beta_\pm^2/\alpha_{\rm ref}\). No one-point matrix element is
identified with \(\beta_\pm\).

Han supplies the boundary blocks
\(B_{\boldsymbol\varsigma}\in\mathbf{Cyl}^{*}\) and leaves the finite
coefficients \(b_{\boldsymbol\varsigma}\) as matching data. A graviton
two-point read also requires a chosen semiclassical boundary state. Those
choices determine the pair \((\beta_+,\beta_-)\).

For a general rotationally covariant packet, the finite tests are

\[
\boxed{
\beta_+(\mathfrak P_{\rm TT})\stackrel{?}{\ne}0,
\qquad
\beta_-(\mathfrak P_{\rm TT})\stackrel{?}{\ne}0.
}
\]

Under [IF-PAR], they reduce to the single common test

\[
\boxed{
\beta_{\rm TT}(\mathfrak P_{\rm TT})
\stackrel{?}{\ne}0.
}
\]

These values cannot be inferred from the symbol \(O(A_{\rm cut}^{-1})\)
alone. They are obtained from the connected two-insertion boundary-block
evaluation on the selected physical boundary state.

---

## 10. Minimum two-polarization reader [THM]

Take the smallest boundary representation carrying spin two:

\[
j=1,
\qquad
|\Psi_{\rm link}\rangle=|1,1\rangle.
\]

For a propagation axis in the \(z\)-direction, use the two unnormalized TT polarization operators

\[
\boxed{
Q_+
:=
L_x^2-L_y^2
=
\frac12(L_+^2+L_-^2),
}
\]

and

\[
\boxed{
Q_\times
:=
L_xL_y+L_yL_x
=
\frac{1}{2{\rm i}}(L_+^2-L_-^2).
}
\]

Since

\[
L_-^2|1,1\rangle=2|1,-1\rangle,
\qquad
L_+^2|1,1\rangle=0,
\]

we obtain

\[
\boxed{
Q_+|1,1\rangle=|1,-1\rangle,
\qquad
Q_\times|1,1\rangle={\rm i}|1,-1\rangle.
}
\]

Both one-point reads vanish,

\[
\langle Q_+\rangle
=
\langle Q_\times\rangle
=0,
\]

while the symmetrized connected covariance is

\[
\boxed{
\frac12
\left\langle
Q_AQ_B+Q_BQ_A
\right\rangle_c
=
\delta_{AB},
\qquad
A,B\in\{+,\times\}.
}
\]

The unsymmetrized connected correlator is

\[
\boxed{
\langle Q_AQ_B\rangle_c
=
\delta_{AB}+{\rm i}\varepsilon_{AB},
\qquad
\varepsilon_{+\times}=1.
}
\]

The \({\rm i}\varepsilon\) term is helicity-odd. Symmetrization removes it;
rotational covariance alone does not.

Thus the minimum boundary reader carries two independent, equal, nonzero TT polarizations. In this normalization its local spin-two strength is one in each polarization.

For general \(j\ge1\),

\[
\|Q_+|j,j\rangle\|^2
=
\|Q_\times|j,j\rangle\|^2
=
j(2j-1)>0.
\]

This closes the local TT-reader calculation. The remaining overlap asks how this reader couples through the first-order Han boundary functional to the already-calculated massless carrier.

---

## 11. Exact packet for the final overlap [DEF]

The last evaluation has the finite input packet

\[
\boxed{
\mathfrak P_{\rm TT}
=
\bigl(
\mathcal K_-,
\Gamma_\Sigma,
k_0,
\gamma,
\lambda_{\rm Han},
b_{\boldsymbol\varsigma},
\Psi_\Sigma,
Q_+,
Q_\times,
\eta_\Sigma,
\alpha_{\rm ref}
\bigr).
}
\]

Its entries are:

| Coordinate | Required value |
|---|---|
| \(\mathcal K_-\) | simply connected root interior with a nonempty internal fluctuation block |
| \(\Gamma_\Sigma\) | its declared boundary graph with two probed boundary locations |
| \(k_0\) | even condensation label; the minimum is \(k_0=2\) |
| \(\gamma,\lambda_{\rm Han}\) | Han parameters selecting the stated saddle |
| \(b_{\boldsymbol\varsigma}\) | finite complete-amplitude boundary-sector vector |
| \(\Psi_\Sigma\) | physical boundary state; minimum probed link spin \(j=1\) |
| \(Q_+,Q_\times\) | the two metric-shear insertions calculated above |
| \(\eta_\Sigma\) | physical quotient/rigging map |
| \(\alpha_{\rm ref}\) | refinement-to-physical-momentum normalization |

For a fixed packet, the connected two-insertion boundary-block evaluation
determines \(W_{\rm TT}\), and therefore determines the degree-correct reduced
couplings

\[
\boxed{
\beta_\pm(\mathfrak P_{\rm TT})
=
\left\|
(P_T\otimes I_3)
\mathcal B_2(0;\mathfrak P_{\rm TT})^\dagger t_\pm
\right\|.
}
\]

The two-point pole coefficients are
\(12\beta_\pm^2/\alpha_{\rm ref}\). Under [IF-PAR], the common coupling is
\(\beta_{\rm TT}=\beta_+=\beta_-\).

Every coordinate of the calculation is now named. No operator or physical carrier remains to be invented.

---

## 12. Current receipt

| Item | Receipt |
|---|---|
| First propagating order | \(A_{\rm cut}^{-1}\) [SRC-HAN] |
| Gauge-fixed transverse quadratic carrier | \(-\mathbb H_t=C_2d_1^*d_1\otimes I_3\) [SRC-HAN] |
| Han-spectrum normalization | \(C_2=1/12\) [DER-HAN] |
| Gaussian convention | Laplace-type \(t\)-block of Han's \(e^S\) stationary-phase integral [SRC-HAN] |
| First transverse covariance | \(G_{t,1}=12(d_1^*d_1)^{-1}\otimes I_3\) [THM] |
| Long-wave connection pole | positive \(1/p^2\) [IF-REF] |
| Local boundary spin-two metric operator | nonzero on boundary links with \(j\ge1\) [THM] |
| Minimum \(j=1\) TT covariance | \(\operatorname{diag}(1,1)\) in \((+,\times)\) [THM] |
| Rotationally covariant TT residue | \(Z_+^{-1}\Pi_{+2}+Z_-^{-1}\Pi_{-2}\) [IF-REF, IF-ROT] |
| Parity-conditioned scalar residue | \(Z_h^{-1}=12\beta_{\rm TT}^2/\alpha_{\rm ref}\) [IF-REF, IF-ROT, IF-PAR] |
| Fixed-packet complete-amplitude survival | \(\beta_\pm(\mathfrak P_{\rm TT})\ne0\), or common \(\beta_{\rm TT}\ne0\) under parity [OPEN-OVERLAP] |

\[
\boxed{
\textbf{CARRIER + LOCAL TT READER CLOSED}
\quad\big|\quad
\textbf{FINITE HELICITY OVERLAP OPEN}.
}
\]

---

## Repair receipt from v0.4

| Audit item | v0.5 disposition |
|---|---|
| X1 Schur/helicity step | Replaced the scalar-from-rotation claim by \(Z_+^{-1}\Pi_{+2}+Z_-^{-1}\Pi_{-2}\); scalar form now requires [IF-PAR] |
| X2 Gaussian convention | Declared Han's \(e^S\), \(\operatorname{Re}S\le0\) convention and the real negative Laplace-type \(t\)-block used for the covariance |
| X3 \(\beta\) degree | Defined \(\beta_\pm\) once as linear-response norms; the connected two-point pole carries \(\beta_\pm^2\) |
| X4 thin spaces | Restored \(C_2\,d_1^*d_1\), \(d_{k_0}^2\), and \(\alpha_{\rm ref}\,p^2\) |
| X5 ledger and graph name | Marked the residue conditional and standardized the boundary graph as \(\Gamma_\Sigma\) |

---

## Repair receipt from v0.5

| Audit item | v0.6 disposition |
|---|---|
| Y1 response degree | The connected two-insertion evaluation now terminates at the Gram residue \(W_{\rm TT}\), which determines \(\beta_\pm\); it no longer claims to reconstruct \(\mathcal B_2(0)\) |
| Y2 covariance mark | Added [IF-ROT] to the claim marks, §8 hypothesis, and both dependent receipt rows |

---

## Source authority

1. Muxin Han, *Ultraviolet Fixed Point in Covariant Loop Quantum Gravity*, arXiv:2602.18665 (2026), especially Eqs. (79)--(84), (111), (120)--(125), and (138)--(142).  
   <https://arxiv.org/abs/2602.18665>
2. *Contact Recognition Continuum*, ed. 1.15, p. 25.
3. *Continuum Closure in Covariant LQG*, 15 September 2026, Eqs. (40)--(44).
4. Eugenio Bianchi and You Ding, *Lorentzian Spinfoam Propagator*, arXiv:1109.6538, especially the boundary metric and connected two-point definitions.  
   <https://arxiv.org/abs/1109.6538>
5. Bianca Dittrich and Athanasios Kogios, *From Spin Foams to Area Metric Dynamics to Gravitons*, arXiv:2203.02409.  
   <https://arxiv.org/abs/2203.02409>
6. *Mirror Recognition Single Composition Map — Unitary Phase and TT Fold*, v0.2.
