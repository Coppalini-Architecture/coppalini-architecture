# Closure Repair Receipt v0.3

## Certified finite spine

\[
Q=\begin{pmatrix}1&1\\1&0\end{pmatrix},\quad
C=\begin{pmatrix}0&-1\\1&0\end{pmatrix},\quad
G=[Q,\Omega]=\begin{pmatrix}-2&1\\1&2\end{pmatrix},\quad
H=CS,\quad G^2=5I.
\]

The signed root action

\[
\langle S,H\rangle=\{\pm I,\pm S,\pm H,\pm C\}
\]

is the order-eight dihedral group of a square. The finite address carrier is

\[
\mathcal A_8=\{\infty\}\sqcup\mathbb Z_7,
\qquad
E(K_8)=\bigsqcup_{r\in\mathbb Z_7}\mathsf M_r.
\]

Its exact counts are

\[
|\mathcal A_8|=8,
\qquad |E(K_8)|=28=7\cdot4,
\qquad
\binom83=56.
\]

The baseline matching is

\[
\mathsf M_0=
\{\mathrm{Gravity\! -\! Light},\
\mathrm{Memory\! -\! Motion},\
\mathrm{Time\! -\! Scope},\
\mathrm{Horizon\! -\! Silence}\}.
\]

## Repaired closure

| Relation | Closed form | Receipt |
|---|---|---|
| Horizon | \(\mathcal H_{\rm hor}=\partial\mathcal V\) | Horizon Silence HS.1 |
| Thermodynamic work | \(dU_{\rm th}=T_{\rm th}dS_{\rm th}-p\,dV+\sum_i\mu_i dN_i+\sum_aY_a dX_a\) | HS.3 |
| Occurrence | \(\mathsf{Occ}_J=(\mathfrak I_J;\Theta,x,\rho_J(x),\kappa,\boldsymbol\varepsilon,\theta_J(x))\) | shared occurrence type |
| Admission | \(\Gate=\mathsf{can}\land\mathsf{Complete}\land\theta=1\) | HS.15 |
| Residual | \(\boldsymbol\varepsilon(p)=(\varepsilon_{\rm drop},\varepsilon_{\rm add},\varepsilon_{\rm strength})(p)\) | HS.16 |
| Silence | \(\mathsf{Silence}_{\rm fit}(p)=1\Longleftrightarrow\mathsf{Complete}(p)\) for typed candidates | HS.19 |
| Scope receipt | \(\Phi:\mathbb R/2\pi\mathbb Z\to\mathcal P(V^\times)\), \(\Phi(\pi)=\mathsf{Silence}_{\rm scope}\) | Time Scope TS.4a--TS.6 |
| Potential reconstruction | \(h_{ijk}=0\) on the 21 triangles through \(\infty\) iff \(d_{ij}=s_j-s_i\) | HS.22 |
| Triangle rank | \(\operatorname{rank}\mathbf h=21\), \(\dim\ker\mathbf h=7\) | HS.23 |
| Cyclic action | \(\tau(\mathsf M_r)=\mathsf M_{r+1}\), \(\tau^7=I\) | HS.24--HS.25 |
| Operator action | \(\varrho(\tau^r)=I_2\oplus e^{(2\pi r/7)C}\) | Gravity Light GL.11g--GL.11j; Horizon Silence HS.28--HS.29 |

## Exact carrier boundary

The address carrier \(\mathcal A_8\), the signed root action
\(\langle S,H\rangle\), and the Lorentzian operator carrier
\(\widetilde V\) have separate types. Their common relation is the cyclic
layer coordinate \(r\in\mathbb Z_7\):

\[
r\longmapsto\bigl(\mathsf M_r,\varrho(\tau^r)\bigr).
\]

The graph ledger therefore carries every pair relation once, and the operator
carrier realizes the layer transport faithfully. A physical edge realization
is carried by its own interface

\[
\mathfrak I_J=(J,\Gamma_J,\operatorname{Src}_J;A_J,X_J,Y_J,T_J,
\Sigma_J,\operatorname{Con}_J,\rho_J,O_J,K_J,B_J,\theta_J).
\]

The M0 pair interfaces are developed by the four cards. The remaining twenty-four
edges have their exact combinatorial address and common cyclic carrier; their
observable, calibration, residual, and experiment-specific receipt remain
individual interface work.

## Executable receipt

`verify_four_papers_v0_3.py` checks the root identities, all 28 edges, the
seven matching layers, cyclic transport, the exact rank-21 triangle system,
potential reconstruction, namespace repairs, and continuous Horizon equation
tags HS.0 through HS.29.

`verify_z7_lorentz_extension_v0_2.py` checks the \(\mathbb Z_7\) factorization
and an exact cyclotomic realization of the transverse rotation block. Its
rotation, metric, phase, and mirror identities are checked as algebraic
equalities in \(\mathbb Q[\zeta_7,i]\), without floating-point arithmetic.
