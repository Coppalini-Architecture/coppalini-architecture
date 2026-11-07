# The Structure of Survival

## Lean algebraic proof from v66

### Jurisdiction

The exact algebraic carrier is \(V=\mathbb R^2\), followed by the quotient reader \(\mathbb R/\varpi\mathbb Z\), the four-state phase carrier \(\mathbb Z/4\mathbb Z\), and an append-only ordered receipt ledger. The receipt and fresh-address laws are stipulated protocol rules. Physical and biological realizations retain their native governing equations and empirical conditions.

### Definitions

Let

\[
Q=\begin{pmatrix}1&1\\1&0\end{pmatrix},
\qquad
\Omega=\begin{pmatrix}0&1\\-1&0\end{pmatrix},
\qquad
G=[Q,\Omega].
\]

Set

\[
H=\frac{G}{\sqrt5},
\qquad
S=\frac{2Q-I}{\sqrt5},
\qquad
L_s=e^{sS}.
\]

Write

\[
\Phi=\frac{1+\sqrt5}{2},
\qquad
\Psi=\frac{1-\sqrt5}{2},
\qquad
v_\Phi=\binom{\Phi}{1},
\qquad
v_\Psi=\binom{\Psi}{1}.
\]

On

\[
X=\{av_\Phi+bv_\Psi:ab\neq0\},
\]

define

\[
\lambda(av_\Phi+bv_\Psi)=\log\left|\frac ab\right|,
\qquad
\varpi=2\log\Phi,
\qquad
\rho_{\rm ax}(z)=[\lambda(z)]_{\varpi\mathbb Z}.
\]

Let \(L_{\rm ax}=L_{\log\Phi}\). On \(P_4\times X\), with \(P_4=\mathbb Z/4\mathbb Z\), define

\[
F(r,z)=
\begin{cases}
(r+1,z),&r=0,1,2,\\
(0,L_{\rm ax}z),&r=3,
\end{cases}
\qquad
D(r,z)=\bigl(i^r,\rho_{\rm ax}(z)\bigr).
\]

### Theorem

For every \((r,z)\in P_4\times X\):

\[
\boxed{
\begin{gathered}
L_s^{\mathsf T}GL_s=G,\\
HL_sH=L_s^{-1},\\
F^4(r,z)=(r,L_{\rm ax}z),\\
D(F^4(r,z))=D(r,z),\\
L_{\rm ax}z\neq z,\\
\lambda(L_{\rm ax}z)-\lambda(z)=\varpi.
\end{gathered}}
\]

Hence the declared form is invariant, the visible reader returns, and the lifted address advances by one exact period.

If each completed traversal appends the single receipt

\[
\mathfrak r_n=
(\operatorname{Ref}_n,\Delta_n,y_n,\Theta_n),
\qquad
R_{n+1}=R_n\frown\mathfrak r_n,
\]

with \(\Delta_n=\varpi\), \(y_n=\rho_{\rm ax}(z_n)\), \(z_n=L_{\rm ax}^nz_0\), and \(\Theta_n=n\), then

\[
\boxed{
\sum_{n=1}^{N}\Delta_n
=\lambda(z_N)-\lambda(z_0)
=N\varpi,
\qquad
\rho_{\rm ax}(z_N)=\rho_{\rm ax}(z_0).
}
\]

The returned form and the accumulated traversal are therefore simultaneously recoverable.

Finally, fix a jurisdiction

\[
\Gamma_J=(\mathsf{Condition},\mathsf{Constraint},
\mathsf{SourceAuthority},\mathsf{Namespace})
\]

with typed domain

\[
D_{\Gamma_J}=\{\sigma:\exists\tau,\ \Gamma_J\vdash\sigma:\tau\},
\qquad
\mathsf{Gate}_{\Gamma_J}:D_{\Gamma_J}
\longrightarrow\{\mathsf{can},\mathbf2\},
\]

where \(\varnothing=\mathsf{UNTYPEABLE}\), \(\emptyset_{\rm set}\) is set-theoretic emptiness, \(\mathbf2\) is the typed Refusal/Fold value, and

\[
\boxed{\mathsf{Ad}(x)\Longrightarrow C_J(x).}
\]

Define

\[
N_J(y)=\{z:y\leadsto_Jz,\ z\in D_{\Gamma_J},\ C_J(z)=1\},
\qquad
\theta_J(y)=1\iff N_J(y)\neq\emptyset_{\rm set}.
\]

For a contact \(p\), define

\[
\begin{aligned}
\mathsf{Admit}(y\mid p,J)\iff{}&
\mathsf{Typed}_J(y)
\land\mathsf{Gate}_J(y)=\mathsf{can}\\
&\land\varepsilon_{\rm drop}(y)=0
\land\varepsilon_{\rm add}(y)=0\\
&\land\varepsilon_{\rm strength}(y)=0
\land\theta_J(y)=1,
\end{aligned}
\]

At the recognition state, let

\[
\mathsf{Enough}_n
\iff
\mathsf{Complete}(\mathrm{Pkt}_{n,8})
\land A_n=\{y_n\}.
\]

If \(\mathsf{Enough}_n\) holds, the protocol appends exactly one receipt, \(\theta_J(y_n)=1\), and every admitted later contact receives a strictly greater occurrence address, then the present comparison closes and every admitted successor receives a fresh address while the completed receipt remains an unchanged prefix of the ledger.

### Proof

Direct multiplication gives

\[
G=Q\Omega-\Omega Q
=\begin{pmatrix}-2&1\\1&2\end{pmatrix},
\qquad
G^2=5I,
\qquad
\det G=-5.
\]

Thus \(G\) is a nondegenerate symmetric form of signature \((1,1)\), and

\[
H^2=I.
\]

With \(C_1=-\Omega\), direct calculation gives

\[
S^2=I,
\qquad
C_1^2=-I,
\qquad
C_1S=-SC_1,
\qquad
H=C_1S.
\]

Since \(S^{\mathsf T}=S\),

\[
S^{\mathsf T}G+GS
=\sqrt5\,(SC_1S+C_1S^2)
=\sqrt5\,(-C_1+C_1)
=0.
\]

Therefore

\[
\frac d{ds}\bigl(L_s^{\mathsf T}GL_s\bigr)
=L_s^{\mathsf T}(S^{\mathsf T}G+GS)L_s
=0.
\]

At \(s=0\), \(L_0=I\), so

\[
L_s^{\mathsf T}GL_s=G.
\]

Also,

\[
HSH=(C_1S)S(C_1S)=C_1^2S=-S,
\]

and consequently

\[
HL_sH=e^{sHSH}=e^{-sS}=L_s^{-1}.
\]

The characteristic equation of \(Q\) is \(t^2-t-1=0\). Hence

\[
Sv_\Phi=v_\Phi,
\qquad
Sv_\Psi=-v_\Psi.
\]

For \(z=av_\Phi+bv_\Psi\in X\),

\[
L_sz=e^sav_\Phi+e^{-s}bv_\Psi,
\]

so

\[
\lambda(L_sz)
=\log\left|\frac{e^sa}{e^{-s}b}\right|
=\lambda(z)+2s.
\]

At \(s=\log\Phi\),

\[
\lambda(L_{\rm ax}z)=\lambda(z)+\varpi.
\]

Reduction modulo \(\varpi\mathbb Z\) gives

\[
\rho_{\rm ax}(L_{\rm ax}z)=\rho_{\rm ax}(z).
\]

Because \(ab\neq0\) and \(\Phi\neq1\), the two nonzero eigencoordinates scale by the distinct factors \(\Phi\) and \(\Phi^{-1}\); therefore \(L_{\rm ax}z\neq z\).

By the definition of \(F\), four applications advance the phase coordinate through one complete cycle and apply \(L_{\rm ax}\) exactly once:

\[
F^4(r,z)=(r,L_{\rm ax}z).
\]

The phase component \(i^r\) has returned, and the quotient equality proved above returns the second component of \(D\). Thus

\[
D(F^4(r,z))=D(r,z).
\]

For the trajectory \(z_n=L_{\rm ax}^nz_0\), each lifted increment equals \(\varpi\). Telescoping yields

\[
\sum_{n=1}^{N}\Delta_n
=\sum_{n=1}^{N}\bigl(\lambda(z_n)-\lambda(z_{n-1})\bigr)
=\lambda(z_N)-\lambda(z_0)
=N\varpi.
\]

Every quotient step is the identity, so \(\rho_{\rm ax}(z_N)=\rho_{\rm ax}(z_0)\). Ordered concatenation gives

\[
\operatorname{dropLast}(R_n\frown\mathfrak r_n)=R_n,
\qquad
\operatorname{last}(R_n\frown\mathfrak r_n)=\mathfrak r_n,
\]

which proves exact recovery of the prior ledger and the new traversal receipt.

For the continuation claim, \(\theta_J(y_n)=1\) means that the typed constraint-satisfying successor set is nonempty. The strictly increasing address rule is injective, so admitted contacts have pairwise distinct, totally ordered addresses. Append-only update preserves each earlier ledger as a prefix of every successor ledger. Hence a later admitted contact opens fresh scope without overwriting the completed occurrence. \(\square\)

### Closure

The exact dependency is

\[
\boxed{
\text{address}
\longrightarrow\text{Difference}
\longrightarrow\text{invariant transport}
\longrightarrow\text{returned readout}
\longrightarrow\text{retained receipt}
\longrightarrow\text{lawful successor}.
}
\]

Equivalently,

\[
\boxed{
\mathsf{Condition}\longrightarrow
\mathsf{Constraint}\longrightarrow
\mathsf{Fit}\longrightarrow
\mathsf{Function}.
}
\]

The algebraic witness is

\[
\boxed{
D(F^4(r,z))=D(r,z),
\qquad
F^4(r,z)\neq(r,z),
\qquad
R_{n+1}=R_n\frown\mathfrak r_n.
}
\]

**Center returns. Form closes. Motion continues.**
