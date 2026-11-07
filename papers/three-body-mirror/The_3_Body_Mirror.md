# The 3 Body Mirror

*Exact Return, Fibonacci Conjugacy, and the Nonlinear Boundary*

**Anthony Vito Coppa** · Coppalini Architecture · 7 November 2026  
**Status:** Corrected manuscript for mathematical review (not a universal three-body solution)  
**Verification:** `verify_euler_birkhoff_c1.py` and `audit_c1.py` (provenance disclosed below).

## Abstract

We give an explicit realization of a mirror–return structure in the planar Newtonian three-body problem. With known masses and complete relative-position vectors in a common oriented frame, an observer reconstructs the barycentric configuration without knowing their own translational trajectory. An orthogonal reflection, composed with time reversal, is a reversing symmetry of the full collision-free flow. For the equal-mass Euler collinear relative equilibrium, a two-dimensional hyperbolic variational sector is conjugate, at a declared sampling interval, to $Q^2$ for the Fibonacci matrix $Q=\bigl(\begin{smallmatrix}1&1\\1&0\end{smallmatrix}\bigr)$, with the gravitational reversor corresponding to an exact root mirror $H$. The one-dimensional local strong stable and unstable manifolds admit compatible analytic linearizations: their union carries a nonlinear conjugacy to $Q^2$ on its two eigenlines. The fourth-order Birkhoff coefficient is evaluated exactly and independently verified to be nonzero, obstructing formal and smooth linearization beyond that cross in the specified local saddle dynamics. The result supplies an exact physical witness, with an explicit boundary; it does not assert a general closed-form solution of the three-body problem or an astronomically selected Fibonacci period.

## The ordinary physical statement

A person moving with a system can still locate its parts relative to one another. The origin of observation moves; the differences remain available. A mirror can exchange orientations without changing gravitational distances. Run a reflected trajectory backward, and Newton’s equations admit it as an exact solution.

Near one classical rotating three-body orbit, small differences grow and shrink along two distinguished directions. At a chosen interval those factors are the two Fibonacci eigenvalues $\varphi^2$ and $\varphi^{-2}$. This identification is exact for the linearized motion and, after a local change of coordinates, exact along the nonlinear stable and unstable branches. A separately calculated fourth-order coefficient shows why the same linear description cannot be extended without changing the dynamics.

The governing question is therefore concrete: *what does the mirror preserve, what does the chosen reader resolve, and where does the exact agreement stop?*

## Interior reference and barycentric reconstruction

Let the positions of three positive masses be $r_i(t)\in\mathbb R^2$, and let an observer occupy $h(t)\in\mathbb R^2$. Suppose the masses $m_i>0$ are known and the observer reads simultaneous relative vectors in a common oriented frame: $$q_i=r_i-h,\qquad M=\sum_{i=1}^3m_i,\qquad \bar q=\frac{1}{M}\sum_i m_iq_i.
\tag{1}$$

<div class="proposition">

**Proposition 1** (Interior-to-barycentric identity). *If $R_{\rm CM}=M^{-1}\sum_i m_i r_i$, then $$\boxed{q_i-\bar q=r_i-R_{\rm CM}.}
\tag{2}$$*

</div>

<div class="proof">

*Proof.* Equation (1) gives $\bar q=R_{\rm CM}-h$. Subtracting yields Equation (2). The observer trajectory cancels, including any translational acceleration. ◻

</div>

The reconstructed configuration is centered at the three-body barycenter. Absolute translation and global orientation are gauge choices unless separately fixed by measured data. The identity concerns the classical relative configuration; it imposes no constraint on an observer’s consciousness or biological state.

## Newtonian mirror and the root metric

Write $\mathsf G_{\!N}$ for Newton’s constant. The collision-free planar equations are $$\ddot r_i=\mathsf G_{\!N}\sum_{j\ne i}m_j\frac{r_j-r_i}{\|r_j-r_i\|^3},\qquad i=1,2,3.
\tag{3}$$

For every planar orthogonal matrix $D$, relative distances are preserved. Hence, if $r_i(t)$ solves Equation (3), so does $D r_i(-t)$. On phase space the operation $$\mathscr R_D(r,p)=(Dr,-Dp)
\quad\text{satisfies}\quad
\boxed{\mathscr R_D\Phi_t=\Phi_{-t}\mathscr R_D,}
\tag{4}$$ where $\Phi_t$ denotes Newtonian evolution on its collision-free domain.

Now fix the exact two-dimensional root: $$Q=\begin{pmatrix}1&1\\1&0\end{pmatrix},\qquad
\Omega=\begin{pmatrix}0&1\\-1&0\end{pmatrix},\qquad
G=[Q,\Omega]=\begin{pmatrix}-2&1\\1&2\end{pmatrix},
\tag{5}$$ $$H=\frac{G}{\sqrt5},\qquad
S=\Omega H=\frac{2Q-I}{\sqrt5},\qquad
\varphi=\frac{1+\sqrt5}{2}.
\tag{6}$$

Direct multiplication verifies $$\begin{aligned}
H^2=S^2&=I, & H^TH=S^TS&=I, & \det H=\det S&=-1, \tag{7}\\
H^TGH&=G, & S^TGS&=-G, & HSH&=-S, \tag{8}\\
Q^2&=e^{2(\log\varphi)S}, && HQ^2H=(Q^2)^{-1}.\tag{9}
\end{aligned}$$

These give two separately typed facts. Both $H$ and $S$ are *Euclidean isometries*, so they take Newtonian solutions to solutions. The auxiliary split form $G$ is preserved by $H$ and sign-reversed by $S$. Thus the “metric flip” in Equation (8) is a precise statement about the root’s signature-$(1,1)$ form, not an inversion of the positive Euclidean distance used by gravity.

The matrix $Q$ itself has determinant $-1$ and cannot be the positive-time map of a continuous real planar flow. Its square has determinant $+1$, and Equation (9) displays a real flow realization. The choice of $Q^2$ therefore has a structural, rather than merely notational, role.

## An exact Euler three-body witness

Choose equal masses $m>0$. Let $e_H=(1,\varphi^3)/\sqrt{10+4\sqrt5}$ be the unit $+1$ eigenaxis of $H$ (distinct from the $Q^2$ eigenvector $u_+$ below), and set $$r_1(0)=-ae_H,\qquad r_2(0)=0,\qquad r_3(0)=ae_H,\qquad a>0.$$ In an orthonormal frame aligned with $e_H$ these positions are $(-a,0)$, $(0,0)$, and $(a,0)$. The positions $$\boxed{r_i(t)=R(\omega t)r_i(0),\qquad
\omega^2=\frac{5\mathsf G_{\!N}m}{4a^3}}
\tag{11}$$ solve Equation (3). The middle body’s net force is zero; each outer body feels $\mathsf G_{\!N}m/a^2+\mathsf G_{\!N}m/(2a)^2=5\mathsf G_{\!N}m/(4a^2)$ toward the center, exactly the centripetal force required by Equation (11). This is the equal-mass Euler collinear relative equilibrium [1, 2]. Direct calculation verifies $He_H=e_H$; this physical mirror axis differs from the Fibonacci eigenvectors exchanged by $H$ in Equation (17).

The specified $H$ is the reflection through the initial line. For any planar rotation $R(\alpha)$, $$HR(-\alpha)=R(\alpha)H,
\qquad\text{hence}\qquad
\boxed{Hr_i(-t)=r_i(t).}
\tag{12}$$ The full nonlinear orbit therefore has an exact physical mirror inverse. In the corotating, rotation-reduced coordinates, the orbit is an equilibrium $\mathsf E$ fixed by the reversing operation.

## Linearized transport and Fibonacci conjugacy

Set $m=a=1$ and $\mathsf G_{\!N}=4/5$. Then $\omega=1$ and the total angular momentum is $\ell=2$. Jacobi reduction of translation and rotation, at fixed $\ell$, gives canonical variables $(r,x,y;p,u,v)$ with Hamiltonian $$\begin{aligned}
\mathcal H={}&\frac{p^2+u^2+v^2}{2}+\frac{(2-xv+yu)^2}{2r^2} \notag\\
&-\frac45\left(\frac1{\sqrt2r}+
\frac{\sqrt2}{\sqrt{(r-\sqrt3x)^2+3y^2}}+
\frac{\sqrt2}{\sqrt{(r+\sqrt3x)^2+3y^2}}\right).
\tag{13}
\end{aligned}$$

The Euler equilibrium is $\mathsf E=(\sqrt2,0,0;0,0,0)$. Writing $\rho=r-\sqrt2$, the quadratic Hamiltonian is $$\mathcal H_2=\frac{p^2+\rho^2+u^2+v^2}{2}+uy-vx-\frac{12}{5}x^2+\frac65y^2.
\tag{14}$$ Its Hamiltonian linearization has characteristic polynomial $$\det(\lambda I-A_6)=(\lambda^2+1)(\lambda^2-\nu^2)(\lambda^2+\kappa^2),
\quad
\nu^2=\frac{1+2\sqrt{51}}5,\quad
\kappa^2=\frac{2\sqrt{51}-1}5.
\tag{15}$$

The six-dimensional phase space thus contains one hyperbolic pair $\pm\nu$ and two elliptic pairs $\pm i$, $\pm i\kappa$. Related normal-form analyses of saddle–center–center equilibria appear for the restricted three-body model [4]; the present calculation uses three finite equal masses. In the four-dimensional shape subsystem, which contains the hyperbolic two-plane, use $(x,y,x',y')$ as coordinates. Its generator and reversor are $$A_h=\begin{pmatrix}
0&0&1&0\\0&0&0&1\\29/5&0&0&2\\0&-7/5&-2&0
\end{pmatrix},
\quad
\mathscr R_h=\operatorname{diag}(1,-1,-1,1).
\tag{16}$$

Define $$b=\frac{\sqrt{51}-14}{5\nu},\quad
w_+=\begin{pmatrix}1\\b\\\nu\\\nu b\end{pmatrix},\quad
w_-=\mathscr R_hw_+,
\quad
u_+=\begin{pmatrix}\varphi\\1\end{pmatrix},\quad
u_-=Hu_+=\begin{pmatrix}-1\\\varphi\end{pmatrix}.
\tag{17}$$ Direct calculation gives $$A_hw_\pm=\pm\nu w_\pm,
\qquad Q^2u_\pm=\varphi^{\pm2}u_\pm.$$

<div class="theorem">

**Theorem 1** (Exact linear physical conjugacy). *Let $W=\operatorname{span}\{w_+,w_-\}$ and set $$\sigma_* =\frac{2\log\varphi}{\nu}=0.550489470050798\ldots,
\qquad
C=[w_+\ \ w_-]\,[u_+\ \ u_-]^{-1}.
\tag{19}$$ Then $C:\mathbb R^2\to W$ is an isomorphism and $$\boxed{e^{A_h\sigma_*}C=CQ^2,\qquad \mathscr R_h C=CH.}
\tag{20}$$*

</div>

<div class="proof">

*Proof.* The vectors $u_\pm$ form an eigenbasis of $Q^2$ with eigenvalues $\varphi^{\pm2}$; the vectors $w_\pm$ form an eigenbasis of $A_h$ with eigenvalues $\pm\nu$. By Equation (19), $e^{\pm\nu\sigma_*}=\varphi^{\pm2}$. The first intertwining identity follows on both basis vectors. Both $H$ and $\mathscr R_h$ exchange their respective $+$ and $-$ vectors, giving the second identity. ◻

</div>

The interval $\sigma_*$ is *declared from the growth rate*; no astronomical clock has been shown to select it. More generally, every reversible two-dimensional real hyperbolic sector with rate $\nu>0$ and a reversor exchanging the eigenlines admits the same $Q^2$ conjugacy at the chosen interval $2\log\varphi/\nu$, after compatible scaling of eigenvectors. In general units the physical time is $t_*=\sigma_*/\omega$.

## The nonlinear cross theorem

For the reduced Hamiltonian, the reversing involution is $$\mathscr R(r,x,y,p,u,v)=(r,x,-y,-p,-u,v).
\tag{21}$$ It is anti-symplectic, fixes $\mathsf E$, preserves $\mathcal H$, and obeys Equation (4). The equilibrium has one-dimensional local analytic strong stable and strong unstable manifolds $W^s_{\rm loc}$ and $W^u_{\rm loc}$, exchanged by $\mathscr R$.

<div class="lemma">

**Lemma 1** (Nonlinear mirror conjugacy on the cross). *Let $P=\Phi_{\sigma_*}$ be the time-$\sigma_*$ map of the full reduced Hamiltonian near $\mathsf E$. There are analytic local parametrizations $\chi_+,\chi_-$ of $W^u_{\rm loc},W^s_{\rm loc}$ with $$\begin{aligned}
P\chi_+(s)&=\chi_+(\varphi^2s), &
P\chi_-(s)&=\chi_-(\varphi^{-2}s),\\
\mathscr R\chi_+(s)&=\chi_-(s).&&
\end{aligned}
\tag{22}$$ Consequently, $P$ on the union $W^u_{\rm loc}\cup W^s_{\rm loc}$ is analytically conjugate, branch by branch and compatibly with the mirror, to $Q^2$ on its two eigenlines.*

</div>

<div class="proof">

*Proof.* The vector field in Equation (13) is analytic near the collision-free equilibrium, and its single expanding and contracting real eigenvalues are nonzero. The local strong invariant branches are analytic. The one-dimensional analytic time map on the expanding branch has multiplier $\varphi^2$; Koenigs linearization, or its real-analytic restriction, supplies $\chi_+$ [3]. Set $\chi_-=\mathscr R\chi_+$. The reversing relation yields $P\chi_-=\mathscr RP^{-1}\chi_+=\chi_-(\varphi^{-2}s)$. Identifying the two branch parameters with the root eigenlines $\mathbb Ru_+$ and $\mathbb Ru_-$ completes the conjugacy wherever the local charts are defined. ◻

</div>

The **cross** is the union of two one-dimensional invariant branches meeting at $\mathsf E$. This is a local consequence of the analytic stable-manifold and one-dimensional Koenigs linearization theorems, together with the reversor. Its scope is branchwise, rather than a two-dimensional analytic neighborhood. It does not identify the entire six-dimensional neighborhood with a two-dimensional linear map.

## The fourth-order stopping condition

Let $\{\xi,\eta\}=1$ be a canonically normalized hyperbolic eigenpair, and let $I=\xi\eta$. The Birkhoff normal form of Equation (13), including the contributions from both center modes, contains $$\mathcal H_{\rm NF}=\mathcal H(\mathsf E)+\nu I+\text{center terms}+a I^2+\text{other higher terms}.
\tag{23}$$ The coefficient $a$ is the pure hyperbolic resonant coefficient at degree four.

The cubic Hamiltonian, with $\rho=r-\sqrt2$, has the exact form $$\mathcal H_3=\frac{\sqrt2\rho}{10}
\bigl(-5\rho^2-10uy+10vx+36x^2-18y^2\bigr).
\tag{24}$$ The quartic coefficient of $I^2$ receives both a direct term from $\mathcal H_4$ and the contribution of the canonical Lie transform removing $\mathcal H_3$. Independently implemented symbolic and full six-dimensional Taylor-tensor methods agree: $$\begin{aligned}
 a_{\rm direct}&=-1.547622997565423\ldots,\notag\\
 a_{\rm cubic}&=-1.225471490664213\ldots,\notag\\
 \boxed{a}&=\boxed{-\frac{82891803+215881566\sqrt{51}}{585841760}}
 =-2.773094488229637\ldots.
\tag{25}
\end{aligned}$$

For the time-$\sigma$ map, $\dot\xi=(\nu+2aI)\xi+\cdots$ and $\dot\eta=-(\nu+2aI)\eta+\cdots$. Thus its first pure hyperbolic resonant coefficient is $$\boxed{c_1(\sigma)=2\sigma a\ne0\quad\text{for every }\sigma>0.}
\tag{26}$$ At the declared Fibonacci sampling time, $$\boxed{c_1(\sigma_*)=-3.053118630452643\ldots.}$$

<div class="corollary">

**Corollary 1** (First resonant obstruction for the sampled map). *For the time-$\sigma_*$ map $P$ of the fixed-angular-momentum reduced Hamiltonian, $c_1(\sigma_*)\ne0$ is the first cubic resonant coefficient in its hyperbolic component. Therefore $P$ is not formally conjugate to its full linear map on an open neighborhood by a near-identity time-preserving change of coordinates. Analytic and $C^\infty$ linearizations of this type are likewise obstructed. The analytic conjugacy on the stable/unstable cross remains exact.*

</div>

<div class="proof">

*Proof.* The quartic term $aI^2$ in the Hamiltonian produces the cubic resonant monomial $2a\xi^2\eta$ in the hyperbolic vector field and coefficient $2\sigma_*a$ in the sampled map, after factoring out the linear multiplier. The six eigenvalues of $DP(\mathsf E)$ are $e^{\pm\nu\sigma_*}$, $e^{\pm i\sigma_*}$, and $e^{\pm i\kappa\sigma_*}$. There are no quadratic resonances. For degree-three monomials, a new discrete-time alias resonance would require a center-frequency difference to be an integer multiple of $2\pi/\sigma_*$. Every candidate frequency difference has absolute value at most $4\kappa$; since $4\kappa\sigma_*<2\pi$, all degree-three map resonances are already continuous-time resonances. In particular, the nonzero pure-hyperbolic term $\xi^2\eta$ cannot be removed by a formal near-identity change. Any analytic or $C^\infty$ linearization induces a formal one. On either branch of the cross $I=0$, so the branchwise result in Equation (22) remains exact. ◻

</div>

*Boundary.* This is a differential/formal obstruction; it is not a claim against topological conjugacy. A claim independent of all choices of nonlinear invariant surfaces, or an extension to the complete Sun–Earth–Moon ephemeris, requires its own theorem and evidence. Since $a\ne0$, higher resonant coefficients are unnecessary to establish the stated failure of smooth linearization.

## Independent computational check

Two independently implemented computational checks accompany the exact coefficient. `verify_euler_birkhoff_c1.py` was prepared with ChatGPT (OpenAI) assistance in this project; it symbolically expands Equation (13) and checks the spectrum, eigenvectors, symplectic normalization, and coefficient. `audit_c1.py` was prepared in a separate review with Claude (Anthropic) assistance. It accepts the same reduced Hamiltonian as input, but derives Taylor tensors directly, performs its own generic six-dimensional Lie transform, and independently checks the reduction against the unreduced Newton equations. Their independence concerns the implemented calculations and the raw-equations check, not independent discovery of the starting Hamiltonian.

<div class="center">

| **Check**                                      | **Observed result**  |
|:-----------------------------------------------|:---------------------|
| $|\mathcal H_{\rm reduced}-E_{N\text{-body}}|$ | $4.44\times10^{-16}$ |
| Angular momentum $\ell$                        | $2$                  |
| Max. finite-difference dynamical residual      | $1.41\times10^{-9}$  |
| Canonical Poisson bracket $\{\xi,\eta\}$       | $1$                  |
| Hyperbolic rate $\nu$                          | $1.748305285531431$  |
| Sampling interval $\sigma_*$                   | $0.550489470050798$  |
| Quartic coefficient $a$                        | $-2.773094488229637$ |
| First return coefficient $c_1$                 | $-3.053118630452643$ |

</div>

The small residuals are numerical consistency checks. The exact expressions and proofs establish the mathematical claims; numerical agreement supplies an independent computational receipt. The accompanying files are `verify_euler_birkhoff_c1.py` and `audit_c1.py`.

### Result and scope

**The 3 Body Mirror, in one statement.** From known masses and complete interior relative vectors, a moving observer reconstructs a barycentric three-body configuration. Newtonian dynamics admit an exact reflection–time inverse. At the equal-mass Euler relative equilibrium, sampled hyperbolic variational transport is exactly conjugate to $Q^2$; the full nonlinear flow has mirror-compatible analytic conjugacy on its one-dimensional stable and unstable cross. A nonzero fourth-order coefficient $a$ witnesses the boundary of formal and smooth linearization beyond that cross.

This construction joins three offices that have different mathematical status: **interior reference** is an exact coordinate identity; **mirror return** is an exact physical symmetry; **Fibonacci transport** is an exact conjugacy on a declared variational sector and nonlinear invariant cross. The computed quartic term marks the first nonlinear limit of that representation.

The construction does not solve arbitrary three-body initial conditions in closed form. Its sampling interval is selected mathematically, rather than measured from celestial periods. An empirical Sun–Earth–Moon realization and a biological phase-entrainment realization each demand their own dynamical model, observables, and comparison data. These are separate continuations of a completed local theorem.

**Common-sense closure.** The observer moves with the world. Relative differences still supply a reference. The mirror carries a lawful inverse. The nonlinear system decides exactly how far the linear read can travel.

## References and verification

1. R. A. Broucke, E. Davoust, J. D. Anderson, H. Lass, and L. Blitzer, “Periodic solutions about the collinear Lagrangian solution in the general problem of three bodies,” *Celestial Mechanics* **24** (1981), 63–82. [DOI](https://doi.org/10.1007/BF01228794).
2. K. Yamada and H. Asada, “Collinear solution to the general relativistic three-body problem,” *Physical Review D* **82** (2010), 104019. [DOI](https://doi.org/10.1103/PhysRevD.82.104019), [arXiv:1010.2284](https://arxiv.org/abs/1010.2284).
3. J. Milnor, *Dynamics in One Complex Variable*, 3rd ed. (Princeton University Press, 2006), Theorem 8.2 (Koenigs linearization).
4. À. Jorba and J. Masdemont, “Dynamics in the center manifold of the collinear points of the restricted three body problem,” *Physica D* **132** (1999), 189–213. [DOI](https://doi.org/10.1016/S0167-2789(99)00042-1). Related normal-form context for the restricted model.
