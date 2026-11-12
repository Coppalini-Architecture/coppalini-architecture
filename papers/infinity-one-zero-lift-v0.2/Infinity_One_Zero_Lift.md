[Coppalini Architecture]{.smallcaps}Working edition 0.2 / 11 November 2026

**Infinity One Zero Lift**

The Normal Form of Projective Memory

Anthony Vito Coppa

# Abstract {#abstract .unnumbered}

A visible form can return while its occurrence advances. This paper gives an explicit normal form for that conjunction. The projective involution $$M=\begin{pmatrix}1&0\\1&-1\end{pmatrix}$$ exchanges infinity and one, fixes zero, and has a second fixed address at two. Its determinant-one complex lift has square $-I$ and fourth power $I$. Two explicit changes of coordinates connect this mirror and its four-phase lift to the existing root algebra. The axial carriage of *Linear Infinity* then enters the source-defined four-state escapement. Two consecutive cycles supply eight distinct occurrence addresses; their complete comparison graph has $28=6+16+6$ edges, partitioned into seven four-edge matchings. An agreement scalar and the signed comparison record reconstruct a normalized state exactly. The resulting composition carries the displayed form, the advancing address, and the evidence needed for return in separately recoverable coordinates. The finite construction is accompanied by executable exact checks and a previously elaborated Lean subcertificate.

# The result in common sense {#the-result-in-common-sense .unnumbered}

A clock hand can reach the same position on a later turn. Keeping the turn number makes the two visits distinguishable. Keeping the original reference and the signed differences makes the returned state reconstructible. This construction does both: it counts the traversal and preserves every pairwise comparison in the selected eight-address window.

The opening relation is $$\boxed{\infty\longleftrightarrow1,\qquad0\longleftrightarrow0.}$$ The completed relation is $$\boxed{\text{projective return}\;\longrightarrow\;
\text{counted lift}\;\longrightarrow\;
8\text{ occurrences}\;\longrightarrow\;28\text{ comparisons}.}$$ Every arrow below is a displayed map, a proved identity, or a declared reader. The title names this composition. The analytic and geometric steps have written proofs; the verification ledger states which parts were also executed in each checker.

# Source and scope {#source-and-scope .unnumbered}

The construction composes *Linear Infinity* [@LI], *Mirror Escapement Time Lift* [@METL], Language Mechanics 011 [@LM11], and the finite reconstruction of *Mirror Recognition* [@MR]. The initiating conversation contributes the three projective addresses and the traversal ending at its first $\mathrm{R}^{2}$ marker. Appendix A preserves that traversal. The mathematical result concerns the specified carriers, lifts, and readers; physical uses enter with their own equations and calibration.

# Infinity, one, zero

**Infinity is a projective address. The map carries it to one exactly.**

Work on the real projective line $\mathbb P^1(\mathbb R)$. A point is a nonzero column $(x,y)^\mathsf T$ modulo multiplication by a nonzero real scalar. Fix $$\infty=[1:0],\qquad0=[0:1],\qquad1=[1:1].
 \label{eq:addresses}$$ The source's ordered triples are $\mathsf L=(\infty,0,1)$ and $\mathsf T=(1,0,\infty)$. Here *Light* and *Time* retain their original roles as names of those triples. Their exchange is the first algebraic question.

::: theorem
**Theorem 1** (Unique three-address mirror). *There is exactly one projectivity satisfying $R(0)=0$, $R(\infty)=1$, and $R(1)=\infty$. It is represented by $$M=\begin{pmatrix}1&0\\1&-1\end{pmatrix},\qquad
 R([x:y])=[x:x-y],\qquad R(x)=\frac{x}{x-1}.
 \label{eq:mirror}$$ The affine formula applies for $x\ne1$; the homogeneous formula applies everywhere. Moreover, $$M^2=I,\qquad R(\mathsf L)=\mathsf T,\qquad R(\mathsf T)=\mathsf L.
 \label{eq:triple}$$*
:::

::: proof
*Proof.* Let $A=\left(\begin{smallmatrix}a&b\\c&d\end{smallmatrix}\right)$ be an invertible representative. Fixing zero gives $b=0$ and $d\ne0$. Sending infinity to one gives $a=c\ne0$. Sending one to infinity gives $c+d=0$. Hence $A=aM$. Multiplication gives $M^2=I$, and componentwise application exchanges the triples. ◻
:::

The homogeneous calculations expose the exact signs: $$M\binom10=\binom11,\qquad
 M\binom11=\binom10,\qquad
 M\binom01=\binom0{-1}.
 \label{eq:columns}$$ Zero is fixed projectively. Its chosen vector representative changes sign.

::: proposition
**Proposition 2** (Two fixed addresses). *The fixed points of $R$ are precisely $0$ and $2$.*
:::

::: proof
*Proof.* For $v=(x,y)^\mathsf T$, the columns $v$ and $Mv$ are proportional exactly when $\det(v,Mv)=x(x-2y)=0$. The two resulting projective points are $[0:1]$ and $[2:1]$. Infinity is exchanged with one, so supplies no additional fixed point. ◻
:::

In the affine chart $R(x)=1+1/(x-1)$, so the limit at infinity is one. Equation [\[eq:columns\]](#eq:columns){reference-type="eqref" reference="eq:columns"} realizes the same result directly, without a limiting calculation. The numerical fixed address $2$ belongs to the chosen normalization [\[eq:addresses\]](#eq:addresses){reference-type="eqref" reference="eq:addresses"}; its coordinate is not invariant under arbitrary recharting.

# The lift keeps the sign; the record keeps the visit

**A projective point, a lifted vector, and an occurrence have distinct return periods.**

Since $\det M=-1$, a scalar multiple $\lambda M$ has determinant one exactly when $\lambda^2=-1$. Over $\mathbb C$, the two lifts are $\pm\mathrm iM$. Choose $$U=\mathrm iM,\qquad U^2=-I,\qquad U^4=I.
 \label{eq:lift}$$ Its order is exactly four. The central sign disappears in projective coordinates after two steps and survives in the vector lift.

## An explicit four-phase representation

Let $$C_1=\begin{pmatrix}0&-1\\1&0\end{pmatrix},\qquad
 Z=\begin{pmatrix}1&\mathrm i\\0&\mathrm i\end{pmatrix}.$$ Direct multiplication gives $$U=ZC_1Z^{-1},\qquad
 K=(Z^{-1})^\dagger Z^{-1}=\begin{pmatrix}1&-1\\-1&2\end{pmatrix},
 \qquad U^\dagger K U=K.
 \label{eq:unitary}$$ The leading principal minors of $K$ are $1$ and $1$, so it is positive definite. In the $Z$ basis, the lift is the familiar unitary quarter-turn $C_1$. Its spectrum is $\{\mathrm i,-\mathrm i\}$. This supplies the four-step central-return algebra used by a spin-$\tfrac12$ rotation representation when its rotation action is specified. The compatible inner product is displayed rather than silently assumed to be the standard one in the original $M$ basis.

## Address return and occurrence advance

Fix an opaque run identifier $u$ and write the $n$th occurrence as $o_n=(u,n)$. An elementary counted mirror step is $$\widehat R([v],n)=(R[v],n+1),\qquad
 \widehat R^2([v],n)=([v],n+2).
 \label{eq:countedmirror}$$ The address returns and the visit changes. For a record updated by append, $$\mathcal H_{n+1}=\mathcal H_n\frown\langle o_n,o_{n+1}\rangle,
 \label{eq:history}$$ the two-step record contains two additional transitions. This is the memory condition: the reference and occurrence remain available for the next comparison.

A central lift records a finite parity difference. The integer $n$ records arbitrarily many traversals. To connect the four-phase lift to an advancing geometric coordinate, we now use the published axial carriage and its escapement.

*Source:* The central-return/occurrence distinction is also explicit in [@METL §VI]. The integer and Gaussian-integer identities in this section have the finite Lean witness described in Appendix B.

# The same mirror in the golden root

**The title mirror and the existing root mirror are connected by a stated change of coordinates.**

Retain the source matrices and their assignments: $$Q=\begin{pmatrix}1&1\\1&0\end{pmatrix},\quad
 \Omega=-C_1,\quad G=[C_1,Q]=[Q,\Omega]=\begin{pmatrix}-2&1\\1&2\end{pmatrix}.$$ Put $$H=\frac G{\sqrt5},\qquad S=\frac{2Q-I}{\sqrt5},\qquad
 L_{\mathrm{ax}}=\frac{Q+2I}{\sqrt5}.$$ The identities needed here are $$\begin{aligned}
 Q^2&=Q+I,&G^2&=5I,&H^2=S^2&=I,& S&=HC_1,\
 L_{\mathrm{ax}}^2&=Q^2,&L_{\mathrm{ax}}^{\mathsf T}GL_{\mathrm{ax}}&=G,&HL_{\mathrm{ax}}H&=L_{\mathrm{ax}}^{-1}.
 \label{eq:root}
\end{aligned}$$ For $\Phi=(1+\sqrt5)/2$, spectral decomposition of $S$ gives $L_{\mathrm{ax}}=\exp((\log\Phi)S)$. Its eigenvalues are $\Phi$ and $\Phi^{-1}$.

*Source:* *Linear Infinity*, Theorem 1 and the root construction [@LI].

::: proposition
**Proposition 3** (Transported title chart). *With $$P=\begin{pmatrix}1&2+\sqrt5\\0&\sqrt5\end{pmatrix},$$ the title mirror and its transported carriage are $$PHP^{-1}=M,\qquad
 L_M=PL_{\mathrm{ax}}P^{-1}=\begin{pmatrix}1+\sqrt5&-2-\sqrt5\\1&-1\end{pmatrix},
 \qquad ML_MM=L_M^{-1}.
 \label{eq:bridge}$$*
:::

::: proof
*Proof.* $\det P=\sqrt5\ne0$. The first two identities are direct multiplication in $\mathbb Q(\sqrt5)$. Conjugating $HL_{\mathrm{ax}}H=L_{\mathrm{ax}}^{-1}$ by $P$ proves the third. ◻
:::

The metric travels with the coordinates: $$G_M=P^{-\mathsf T}GP^{-1}=
 \begin{pmatrix}-2&2+\sqrt5\\2+\sqrt5&-4-2\sqrt5\end{pmatrix},
 \quad L_M^{\mathsf T}G_ML_M=G_M.$$ Thus equation [\[eq:bridge\]](#eq:bridge){reference-type="eqref" reference="eq:bridge"} preserves the governing form as well as the mirror law. $P$ is the real mirror/carriage adapter; $Z$ in [\[eq:unitary\]](#eq:unitary){reference-type="eqref" reference="eq:unitary"} is the complex phase adapter. Each transports the structure for which it was defined.

This is the first bridge of the paper: the simple $\infty\leftrightarrow1$ chart belongs to an explicitly related representation of the established mirror algebra. The second bridge is the counted passage from this four-phase representation to the axial lift.

# Linear infinity and the four-step escapement

**One completed phase cycle releases one exact axial step.**

Let $\Psi=(1-\sqrt5)/2$ and, on the upper half-plane, define $$\xi_{\mathrm{ax}}(z)=\frac{\Phi-z}{z-\Psi},\qquad
 \Lambda(z)=\log\frac{\Phi}{|\xi_{\mathrm{ax}}(z)|},\qquad T=2\log\Phi>0.
 \label{eq:axcoord}$$ The coordinate is finite throughout the upper half-plane. Fractional-linear substitution yields $$\xi_{\mathrm{ax}}(L_{\mathrm{ax}}z)=\Phi^{-2}\xi_{\mathrm{ax}}(z),\quad
 \xi_{\mathrm{ax}}(\mathrm i)=-\mathrm i\Phi,\quad
 \Lambda(L_{\mathrm{ax}}z)=\Lambda(z)+T,\quad\Lambda(\mathrm i)=0.
 \label{eq:translation}$$ The last two equalities follow by taking the logarithm of the modulus. On the quotient by $\langle L_{\mathrm{ax}}\rangle$, the position returns. On the cover, the real coordinate advances by $T$ [@LI].

Set $P_4=\mathbb Z/4\mathbb Z$ and use the source escapement [@METL §V]: $$F(p,z)=\begin{cases}(p+1,z),&p=0,1,2,\\(0,L_{\mathrm{ax}}z),&p=3.\end{cases}
 \label{eq:escape}$$

::: theorem
**Theorem 4** (Exact carry). *For $p\in\{0,1,2,3\}$ and $n\ge0$, let $c_n(p)=\lfloor(p+n)/4\rfloor$. Then $$F^n(p,z)=\bigl((p+n)\bmod4,\ L_{\mathrm{ax}}^{c_n(p)}z\bigr).
 \label{eq:carry}$$ In particular, $F^4(p,z)=(p,L_{\mathrm{ax}}z)$.*
:::

::: proof
*Proof.* Each successor increases the phase by one. Exactly $c_n(p)$ of the first $n$ successors cross the boundary from $3$ to $0$. Each such crossing applies $L_{\mathrm{ax}}$ once. This also proves the formula by induction. ◻
:::

## Euler's phase and the recovered address

The circle-valued read $W(z)=\exp(2\pi\mathrm i\Lambda(z)/T)$ satisfies $W(L_{\mathrm{ax}}z)=W(z)$. The independent local dial is $\mathrm i^p$. At the fixed source $z_0=\mathrm i$, Euclidean division gives $$n=4c+p\quad\longmapsto\quad x_n=(p,L_{\mathrm{ax}}^{c}\mathrm i),\qquad
 \Lambda(L_{\mathrm{ax}}^{c}\mathrm i)=cT.
 \label{eq:orbit}$$ This map is injective: phase recovers $p$, and $\Lambda/T$ recovers $c$. On its image its exact inverse is $x_n\mapsto4\Lambda(z)/T+p$. Every four steps the local phase returns and the cycle count increases by one.

The projective pole $\infty$, the unbounded real coordinate $\Lambda$, and the integer occurrence index $n$ retain their declared types. Equations [\[eq:axcoord\]](#eq:axcoord){reference-type="eqref" reference="eq:axcoord"}--[\[eq:orbit\]](#eq:orbit){reference-type="eqref" reference="eq:orbit"} supply the maps between the relevant constructions.

# Two cycles, eight occurrences, twenty-eight seams

**Keep two turns separate, then compare every pair exactly once.**

Fix a cycle $c$. Language Mechanics 011 selects the window $$W_c=\{o_{4(c+\ell)+p}:\ell=0,1,\ p=0,1,2,3\},\qquad j=4\ell+p.
 \label{eq:window}$$ Its eight elements are distinct. Through [\[eq:orbit\]](#eq:orbit){reference-type="eqref" reference="eq:orbit"}, they correspond to $(p,L_{\mathrm{ax}}^{c+\ell}\mathrm i)$. The phase agrees for $j$ and $j+4$, while their axial coordinates differ by $T$ [@LM11; @METL].

Let $E=\mathbb R^{W_c}\cong\mathbb R^8$ be the free address carrier. A general alternating read has the unique expansion $$\omega_D=\sum_{0\le j<k\le7}D_{jk}\,e^j\wedge e^k,
 \qquad\dim\Lambda^2(E^*)=\binom82=28.
 \label{eq:28}$$ Here $\Lambda^2$ denotes the exterior square; $\Lambda(z)$ in [\[eq:axcoord\]](#eq:axcoord){reference-type="eqref" reference="eq:axcoord"} denotes a scalar coordinate. The superscript has a different, explicitly declared operation in these two expressions.

The two-cycle partition gives $$E(K_8)=E(K_4^{(c)})\sqcup E(K_{4,4})\sqcup E(K_4^{(c+1)}),
 \qquad28=6+16+6.
 \label{eq:6166}$$

::: center
![image](assets/incidence.pdf){width=".96\\linewidth"}
:::

**Figure 1.** All eight occurrence vertices and all 28 comparisons, colored by the seven source matchings. Vertices 0--3 belong to cycle $c$; 4--7 belong to cycle $c+1$. Their positions use the recorded projection in Section 9. A crossing is not an additional vertex. Each line represents a comparison, rather than an escapement trajectory.

The full comparison space has 28 independent coordinates. A particular reader may impose relations among their values. Section 7 states those relations explicitly for potential differences and for the reconstructing rank-two record.

# Seven matchings and one complete scan

**Each band reads four disjoint pairs; the seven bands exhaust the window.**

Use the source relabeling $\mathcal A_8=\{\infty\}\sqcup\mathbb Z_7$. In the supplied published SVG, occurrence label $7$ is the distinguished $\infty$ slot and labels $0$--$6$ remain finite. This is a combinatorial relabeling of [\[eq:window\]](#eq:window){reference-type="eqref" reference="eq:window"}. The projective point in [\[eq:addresses\]](#eq:addresses){reference-type="eqref" reference="eq:addresses"} remains separately typed.

For $a\in\mathbb Z_7$, define $$\mathsf M_a=\{\{\infty,a\}\}\cup\{\{a+b,a-b\}:b=1,2,3\}.
 \label{eq:match}$$ All finite arithmetic in this formula is modulo seven.

::: proposition
**Proposition 5** (Complete matching decomposition). *Each $\mathsf M_a$ has four edges and uses every vertex once. The seven matchings partition $E(K_8)$.*
:::

::: proof
*Proof.* The finite endpoints are $a,a\pm1,a\pm2,a\pm3$, all seven residues. The edge $\{\infty,x\}$ belongs only to $\mathsf M_x$. Every finite edge $\{x,y\}$ has the unique midpoint $a=(x+y)/2$ in $\mathbb Z_7$ and one unsigned displacement $b\in\{1,2,3\}$. Thus each edge appears once. ◻
:::

::: center
   $a$     $b=0$     $b=1$   $b=2$   $b=3$
  ----- ----------- ------- ------- -------
    0    $\infty0$    16      25      34
    1    $\infty1$    20      36      45
    2    $\infty2$    31      40      56
    3    $\infty3$    42      51      60
    4    $\infty4$    53      62      01
    5    $\infty5$    64      03      12
    6    $\infty6$    05      14      23
:::

The notation $xy$ abbreviates an unordered edge, not multiplication.

A scanner is now defined, rather than inferred from the geometry: $$q\in\mathbb Z_{28}\longmapsto(a,b)=(q\bmod7,q\bmod4)
 \longmapsto\kappa(a,b)\in E(K_8),$$ where $\kappa(a,0)=\{\infty,a\}$ and $\kappa(a,b)=\{a+b,a-b\}$ otherwise. The inverse coordinate is $$q=8a+21b\pmod{28}.$$ Reduction modulo seven and four verifies both residues, proving the Chinese-remainder bijection. This gives a complete scan [@LM11 §6]. The occurrence counter $n$ and scan counter $q$ keep independent roles until a synchronization rule is supplied.

Let $\mathcal W=\Lambda^2(E^*)$ with its orthonormal wedge basis, and let $P_a$ select the four coordinates in $\mathsf M_a$. Then $$P_aP_b=\delta_{ab}P_a,\qquad\sum_{a=0}^{6}P_a=I_{\mathcal W},\qquad\operatorname{rank}P_a=4.
 \label{eq:resolution}$$ This is the seven-band identity resolution of *Mirror Recognition* [@MR §9].

# The record that returns the state

**Agreement supplies the parallel part. Signed differences supply the rest.**

Fix a normalized reference $m\in\mathbb R^8$ and a normalized state $r\in\mathbb R^8$, expressed in the same ordered occurrence basis. Define $$a=m^\mathsf Tr,\qquad D=mr^\mathsf T-rm^\mathsf T,\qquad
 D_{jk}=m_jr_k-m_kr_j.
 \label{eq:record}$$ These are the signed seam components of the source reconstruction [@MR §8].

::: theorem
**Theorem 6** (Exact reconstruction). *For $\|m\|=\|r\|=1$, $$\boxed{r=am+D^\mathsf Tm,\qquad a^2+\sum_{j<k}D_{jk}^2=1.}
 \label{eq:decoder}$$ Consequently, the read $r\mapsto(a,D)$ is injective for fixed $m$.*
:::

::: proof
*Proof.* $D^\mathsf Tm=(rm^\mathsf T-mr^\mathsf T)m=r-am$. Also, $\sum_{j<k}(m_jr_k-m_kr_j)^2=\|m\|^2\|r\|^2-(m^\mathsf Tr)^2$, by expanding the products and grouping the diagonal and off-diagonal terms. This gives both formulas. Equal records reconstruct equal states. ◻
:::

Writing $B_a=\sum_{\{j,k\}\in\mathsf M_a}D_{jk}^2$ gives the exact band closure $$a^2+\sum_{a'=0}^{6}B_{a'}=1.$$ The full signed $D$ carries the decoder. The seven energies alone omit its signs. At $D=0$, the two normalized possibilities are $r=m$ and $r=-m$; the agreement $a=1$ or $-1$ distinguishes them. The projective read identifies their ray while the signed record preserves their difference.

## Twenty-eight coordinates; reader-specific freedom

The general space in [\[eq:28\]](#eq:28){reference-type="eqref" reference="eq:28"} has dimension 28. Record [\[eq:record\]](#eq:record){reference-type="eqref" reference="eq:record"} is a decomposable exterior product, with matrix rank at most two. With $m$ fixed and $r$ normalized, its allowed records have the seven continuous degrees of freedom of $S^7$. The 28 slots provide a complete redundant comparison record.

A different specialized read is $d_{jk}=s_k-s_j$. It satisfies $$d_{ij}+d_{jk}+d_{ki}=0.
 \label{eq:triangles}$$ Conversely, if [\[eq:triangles\]](#eq:triangles){reference-type="eqref" reference="eq:triangles"} holds on every triangle, fix $s_0=0$ and set $s_j=d_{0j}$; the triangle $(0,j,k)$ yields $d_{jk}=s_k-s_j$. Thus the potential image has dimension seven. The 56 triangle equations on 28 edge coordinates have rank 21. The graph fixes available comparisons; the reader fixes their admissible values [@LM11 §5].

For the uniform reference $m=(1,\ldots,1)^\mathsf T/\sqrt8$, the reconstruction specializes to $$a=\frac{1}{\sqrt8}\sum_jr_j,\qquad D_{jk}=\frac{r_k-r_j}{\sqrt8},\qquad r_j=\frac a{\sqrt8}+\frac1{\sqrt8}\sum_kD_{kj}.$$ Here $\sqrt8$ is exactly the normalization of eight equal reference entries.

# The normal form and its inverse

**The complete read carries both which visit occurred and what state was read.**

The preceding maps now assemble without identifying their carriers. Here *normal form* means uniquely recoverable coordinates after the reference and address conventions are fixed. Fix a run $u$, the initial axial point $\mathrm i$, the eight-address order, and a normalized reference $m$. Each window uses the declared local label $j\mapsto o_{4c+j}$; the cycle $c$ travels in the record. For $n\in\mathbb N$ and $r\in S^7$, write $n=4c+p$ and define $$\mathcal N_m(n,r)=(p,c,a,D),\qquad a=m^\mathsf Tr,\quad D=mr^\mathsf T-rm^\mathsf T.
 \label{eq:nf}$$ The projective operator display can be read from $[U^p]$; the full four-phase value is $U^p$ or $\mathrm i^p$. The axial representative of the cycle is $L_{\mathrm{ax}}^{c}\mathrm i$, and $c=\Lambda(L_{\mathrm{ax}}^{c}\mathrm i)/T$.

::: theorem
**Theorem 7** (Projective-memory normal form). *On the image of [\[eq:nf\]](#eq:nf){reference-type="eqref" reference="eq:nf"}, $$\boxed{\mathcal N_m^{-1}(p,c,a,D)=(4c+p,\;am+D^\mathsf Tm).}
 \label{eq:nfinverse}$$ The source escapement returns the phase after four successors and advances the axial representative by one $L_{\mathrm{ax}}$ step. Two successive cycles supply eight different occurrences. Their seven matching projectors resolve the complete 28-coordinate comparison space, while the signed record reconstructs $r$ exactly.*
:::

::: proof
*Proof.* Euclidean division uniquely recovers $(p,c)$ from $n$ and gives $4c+p=n$. Equation [\[eq:decoder\]](#eq:decoder){reference-type="eqref" reference="eq:decoder"} recovers $r$. Equation [\[eq:carry\]](#eq:carry){reference-type="eqref" reference="eq:carry"} proves the phase return and carry, and [\[eq:translation\]](#eq:translation){reference-type="eqref" reference="eq:translation"} makes different cycle addresses distinct on the selected orbit. Equation [\[eq:window\]](#eq:window){reference-type="eqref" reference="eq:window"} therefore has eight elements. Equations [\[eq:match\]](#eq:match){reference-type="eqref" reference="eq:match"} and [\[eq:resolution\]](#eq:resolution){reference-type="eqref" reference="eq:resolution"} exhaust all pairs. Each component of the asserted inverse has now been supplied. ◻
:::

The inverse is stated on the image because arbitrary tuples $(p,c,a,D)$ need not satisfy normalization or decomposability. For unit $m$, an explicit image test is $$r_*:=am+D^\mathsf Tm,\qquad \|r_*\|=1,\qquad
 a=m^\mathsf Tr_*,\qquad D=mr_*^\mathsf T-r_*m^\mathsf T,$$ together with $p\in\{0,1,2,3\}$ and $c\in\mathbb N$. These conditions are sufficient as well as necessary. The theorem acts on supplied window records; acquisition timing is a separate condition.

## What this closes

The coordinate adapters and construction dependencies are $$M\ \overset{P}{\longleftrightarrow}\ H,\qquad
 U\ \overset{Z}{\longleftrightarrow}\ C_1,$$ $$L_{\mathrm{ax}}\longrightarrow F\longrightarrow W_c\longrightarrow E
 \longrightarrow\mathcal W=\Lambda^2(E^*).$$ For fixed reference $m$, the actual state-reader maps on this carrier are $$r\longmapsto(a,\omega_D)\longmapsto\bigl(a,(P_b\omega_D)_{b=0}^{6}\bigr)
 \longmapsto am+D^{\mathsf T}m=r.$$ The projectors recover $\omega_D$ by summation; its ordered coefficients recover $D$. $P$ and $Z$ are coordinate adapters, $F$ is the published coupling, and $W_c$ is the selected occurrence window. The normal form has a written inverse and an explicit domain. That is the exact sense of closure used in this paper.

# The geometry of the figure

**The picture is generated from the address map. Its lines keep their declared jobs.**

On the window in [\[eq:window\]](#eq:window){reference-type="eqref" reference="eq:window"}, use the display $$v_{\ell,p}=\left(\cos\frac{\pi p}{2},\ \sin\frac{\pi p}{2},\ \ell\right).
 \label{eq:embed}$$ The final coordinate equals the normalized axial separation $(\Lambda(L_{\mathrm{ax}}^{c+\ell}\mathrm i)-cT)/T=\ell$. For the four integer phases, all eight triples in [\[eq:embed\]](#eq:embed){reference-type="eqref" reference="eq:embed"} are integers. They form two separate four-point layers.

The checked page projection is $$A_{\rm draw}=\begin{pmatrix}1&1/5&14/5\\1/7&1&3/5\end{pmatrix}.
 \label{eq:projection}$$ It maps the vertices to the following exact rational positions:

::: center
   $j$   $(\ell,p)$  $A_{\rm draw}v_{\ell,p}$    $j$   $(\ell,p)$  $A_{\rm draw}v_{\ell,p}$
  ----- ------------ -------------------------- ----- ------------ --------------------------
    0     $(0,0)$    $(1,1/7)$                    4     $(1,0)$    $(19/5,26/35)$
    1     $(0,1)$    $(1/5,1)$                    5     $(1,1)$    $(3,8/5)$
    2     $(0,2)$    $(-1,-1/7)$                  6     $(1,2)$    $(9/5,16/35)$
    3     $(0,3)$    $(-1/5,-1)$                  7     $(1,3)$    $(13/5,-2/5)$
:::

Every projected vertex is different, and the verifier checks that none lies in the interior of an unrelated edge. Each unordered pair is drawn once, using its source matching color. Intersections of lines are unmarked. Uniform page scaling and translation finish the layout.

The displayed affine span is three-dimensional, the address carrier is eight-dimensional, and the general alternating comparison space is 28-dimensional. The drawing is a two-dimensional projection of the chosen display. It supplies incidence and address readability; no physical spatial metric is assigned to the page.

## The original double diamond

The double diamond in *Linear Infinity*, printed page 3, is a pair of proof-dependency diagrams. The first constructs $L_{\mathrm{ax}}$ from the root relations. The second carries the positive-projective and signed-Lorentzian readings to typed Contact. Its arrows encode dependencies [@LI]. Figure 1 here instead displays the eight occurrence addresses and their complete comparison set. The two diagrams have stated, complementary functions.

## The publication frame

The cover uses the measured 800-by-1050 Coppalini SVG frame supplied with the five published references: ivory ground, centered title and diagram, seven source-ordered colors, one equation, and author/imprint footer. Its 28 lines are generated from the same edge ledger as Figure 1. The editable SVG, projection, palette, and exact source hashes accompany the manuscript.

# Zeno, optics, and conserved transport

**The same algebra can be used at another interface once its variables are specified.**

## Finite subdivision and its limit

For $q=2^n$, define the two homogeneous columns $X_n=(1-q,1)^\mathsf T$ and $Y_n=(q-1,q)^\mathsf T$. Then $$MX_n=(1-q,-q)^\mathsf T=-Y_n,\qquad
 [MX_n]=[Y_n],\qquad s_n=\frac{q-1}{q}=1-2^{-n}.$$ This is the exact finite-stage correspondence for Zeno's dichotomy. As $n\to\infty$, $[X_n]\to[1:0]$ and $s_n\to1$. The homogeneous equality is algebraic; convergence uses the ordinary real topology. Thus the finite completion is the image of the projective limit. A model of motion in time additionally specifies its time parameter.

## Normalized conjugate distances

Within the ideal paraxial thin-lens model, signed object and image distances obey $$\frac1o+\frac1{d_{\rm im}}=\frac1f.$$ With $x=o/f$ and $y=d_{\rm im}/f$, the relation becomes $xy=x+y$, hence $$y=\frac{x}{x-1}=R(x).$$ Object and image exchange under the same involution. The finite symmetric conjugate-distance condition is $x=y=2$, giving transverse magnification $-1$. The zero address belongs to the projective extension; the physical reciprocal-distance equation requires its nonzero, model-admissible distances. Mitochondrial microlensing enters the original conversation as a biological interface, documented independently in [@Ball]; it supplies no replacement for a measured wave-optical model.

## Euler, transformation groups, and Noether

Euler exponentiation in Section 4 makes the axial coordinate circle-valued. The transformation-group description specifies which forms a motion preserves. Noether conservation enters after an action. For the source Fermi metrics [@LI], choose either $\epsilon=+1$ or $\epsilon=-1$ and the geodesic Lagrangian $$\mathcal L_\epsilon=\tfrac12\left(\dot\delta^2+\epsilon\cosh^2\delta\,\dot\Lambda^2\right).$$ Dots denote derivatives along an affine curve parameter. Since $\partial\mathcal L_\epsilon/\partial\Lambda=0$, its Euler--Lagrange equation gives $$p_\Lambda=\epsilon\cosh^2\delta\,\dot\Lambda,\qquad
 \frac{d p_\Lambda}{dt}=0.$$ This is the precise conserved quantity for the supplied action. The metric signature remains attached to the chosen model. The count 28 arises from the eight-address exterior square, $\sqrt5$ from $G^2=5I$, and $\pi$ from phase-angle normalization. Each constant has its own derivation.

# The source traversal, ending at R²

The initiating sequence is preserved in its original order. Its roles in this edition are as follows.

::: center
  Source address                               Role carried here
  -------------------------------------------- ----------------------------------------------------------------------------------------------------------------------------
  Light / Time                                 Ordered triples $(\infty,0,1)$ and $(1,0,\infty)$; their projective exchange is proved in Section 1.
  Infinity to one                              Exact homogeneous endpoint map $M[1:0]=[1:1]$.
  Memory return                                Counted visit and retained reference; Sections 2, 4, and 8 give the record and inverse.
  Spinor                                       Central lift $U^2=-I$, $U^4=I$ and the explicit compatible phase representation.
  Zeno                                         Finite-stage identity and projective limit in Section 10.
  Beta movement                                Proposed perceptual reader interface: consecutive presentations, a memory state, and a specified temporal read.
  Gödel horizon                                Formal proof-reader boundary, with a theory and its provability relation specified before an incompleteness claim.
  Mitochondrial eye                            The normalized optical equation and the independently reported microlensing observation [@Ball].
  Shadow vision                                Proposed spatial-recognition interface with named sensory input, learning rule, and calibration.
  *Innervisions*; *Songs in the Key of Life*   Artistic references introduced in the conversation as witnesses of inner perception, temporal form, and meaningful return.
  $\mathrm{R}^{2}$                             The user's stopping marker. The subsequent private recognition-codex account lies outside this publication.
:::

## Reader equations and their evidence {#reader-equations-and-their-evidence .unnumbered}

For a perceptual application, an explicit model might have sensor event $s_n$, memory state $m_n$, update $m_{n+1}=\mathcal U(m_n,s_n)$, and read $y_n=\rho(m_n,s_n)$. Those symbols specify a place for an empirical model; a measured update law and observed response must determine its content. No such calibration is supplied by the projective matrix alone.

For the Gödel address, the precise standard hypothesis is a consistent, effectively axiomatized theory extending sufficient arithmetic. The Gödel--Rosser conclusion concerns a sentence undecidable in that named theory [@Rosser]. Addressing a sentence and proving it are separate operations. The finite identities of this paper are exhibited directly.

The artistic references preserve the historical route of the conversation. They introduce no algebraic axioms or claims about an artist's intention. This appendix records the full requested traversal while keeping the mathematical dependencies local and checkable.

# Verification, source custody, and reproduction

**The theorem statements determine what a passing check certifies.**

This edition carries three complementary forms of evidence.

**Written proofs.** The uniqueness and fixed points of the projectivity, the analytic axial translation, the escapement iteration, the matching decomposition, the triangle criterion, and the two inverse maps are proved in the text. The source hypotheses and coordinate adapters are displayed where used.

**Finite Lean certificate.** The unchanged file `ProjectiveReturn.lean`, at source commit `43073ed248bad45c94dd12aaa0dbc00a3ec64875`, has a successful GitHub execution under Lean 4.33.0 [@LeanRun]. It checks the integer matrix involution, chosen endpoint maps, projective zero witness, ordered-triple exchange, Gaussian-integer central-lift powers, the general integer Zeno identity, and counted return at infinity. Its `SameProjective` predicate is a sufficient nonzero-integer scaling witness for the displayed vectors; the paper's full real projective equivalence is defined in Section 1. The certificate has not formalized the real-analysis, entire $K_8$ construction, or empirical interfaces. Lean certification applies to the elaborated statements and their definitions [@LeanManual].

**Exact executable audit.** The supplied geometry verifier was rerun: all 73 checks pass. It uses integer/rational arithmetic and $\mathbb Q(\sqrt5)$ identities, checks the complete 28-edge set against the published SVG, verifies the seven matchings and scanner, and computes ranks seven and 21 for the potential and triangle maps. All 31 manuscript-supplement checks also pass. They check the transported metric, compatible complex inner product, symbolic reconstruction, all projector identities, exact normal-form examples, and the cover's vertex/edge custody. Its full output is included. Finite examples are labeled as examples; universal claims have the proofs given above.

## Run the checks {#run-the-checks .unnumbered}

From the unpacked source bundle:

    python -m pip install -r requirements.txt
    python verification/geometry_audit/verify_graph.py
    python verification/verify_manuscript.py
    python build_cover.py
    pdflatex -halt-on-error Infinity_One_Zero_Lift.tex
    pdflatex -halt-on-error Infinity_One_Zero_Lift.tex

The pinned original Lean file and a local recheck command are provided separately. The public execution receipt is retained by source commit; it is not described as a peer review or as certification of unencoded claims.

## Authorship and edition {#authorship-and-edition .unnumbered}

Anthony Vito Coppa supplied the original observation, the source architecture, the chosen scope, title, and publication reference. Computational assistance was used for algebraic verification, source reconciliation, composition, and typesetting. Working edition 0.2 is a citation-only update to edition 0.1: DOI links have been added to the four cited architecture papers. The mathematical content, figures, and verification artifacts are unchanged. The source checksum manifest fixes this package's files. The manuscript introduces no empirical parameter determination or priority assertion beyond the stated composition.

::: thebibliography
10 Anthony Vito Coppa. *Linear Infinity: Return Without Erasure in a Minimum Two-Form Architecture*. Canonical working edition 0.1, 13 August 2026. Theorem 1; "The double diamond"; printed pp. 12--15 and 23. DOI: [10.5281/zenodo.24150517](https://doi.org/10.5281/zenodo.24150517).

Anthony Vito Coppa. *Mirror Escapement Time Lift*. Canonical working edition 0.1, 22 August 2026. Sections II--VII, especially the escapement theorem in Section V. DOI: [10.5281/zenodo.24150565](https://doi.org/10.5281/zenodo.24150565).

Anthony Vito Coppa. *Occurrence and the Twenty-Eight-Seam Reader: Finite Addressing, Pairwise Difference, and a Complete $7\times4$ Scan*. Language Mechanics 011, standalone edition v0.2, 29 August 2026. Sections 1--8. DOI: [10.5281/zenodo.24150567](https://doi.org/10.5281/zenodo.24150567).

Anthony Vito Coppa. *Mirror Recognition: The Minimum Symmetric Field Closure*. Final form v1.0, typeset working edition, 11 September 2026. Sections 8--9, printed pp. 16--18. DOI: [10.5281/zenodo.24150572](https://doi.org/10.5281/zenodo.24150572).

Anthony Vito Coppa, with computational assistance. *Infinity One Zero Lift: Geometry and Template Audit*. 11 November 2026. Exact coordinate/edge ledgers, 73-check verifier, and five-cover reference lock; included in this package.

*ProjectiveReturn.lean*. Coppalini Architecture repository, commit `43073ed248bad45c94dd12aaa0dbc00a3ec64875`. Lean 4.33.0 execution, GitHub Actions run `43033661694`, job `130566797599`; completed successfully 11 November 2026. [Public execution receipt](https://github.com/Coppalini-Architecture/coppalini-architecture/actions/runs/43033661694). Source file preserved in this package.

The Lean development team. *The Lean Language Reference*, "Validating a Lean Proof" and "Axioms." Consulted 11 November 2026. <https://lean-lang.org/doc/reference/latest/ValidatingProofs/>

John M. Ball, Shan Chen, and Wei Li. "Mitochondria in cone photoreceptors act as microlenses to enhance photon delivery and confer directional sensitivity to light." *Science Advances* **8**(9), eabn2070 (2022). DOI: [10.1126/sciadv.abn2070](https://doi.org/10.1126/sciadv.abn2070).

J. Barkley Rosser. "Extensions of Some Theorems of Gödel and Church." *The Journal of Symbolic Logic* **1**(3), 87--91 (1936). DOI: [10.2307/2269028](https://doi.org/10.2307/2269028).
:::

::: center

------------------------------------------------------------------------

\
**The form returns. The occurrence advances.\
The signed record remains reconstructible.**\
$\displaystyle\infty\longleftrightarrow1,\qquad0\longleftrightarrow0$
:::
