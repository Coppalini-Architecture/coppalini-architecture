# Infinity One Zero Lift — geometry and template audit

**Subtitle held:** The Normal Form of Projective Memory.  
**Work performed:** source return, exact calculation, explicit drawing projection, five-cover comparison.  
**Status:** 73 exact executable checks passed. The new diagram is a technical incidence drawing, not an approved replacement cover. This audit has not been checked in Lean. No repository, website or published paper was modified.

## 1. The correct source chain

**L — Linear Infinity**, canonical working edition 0.1 (13 August 2026), printed pp.2–3, 12–15: the axial coordinate obeys

\[
\Lambda(L_{\rm ax}z)=\Lambda(z)+T,\qquad T=2\log\Phi.
\]

**E — Mirror Escapement Time Lift**, canonical working edition 0.1 (22 August 2026), §V, printed pp.5–6: the stated escapement advances a phase, and applies the axial carriage on the carry from phase 3 to phase 0:

\[
F(p,z)=\begin{cases}(p+1,z),&p<3,\\(0,L_{\rm ax}z),&p=3.\end{cases}
\]
\[
F^{4c+p}(0,z_0)=(p,L_{\rm ax}^{c}z_0),\qquad
\Lambda(L_{\rm ax}^{c}z_0)=\Lambda(z_0)+cT.
\]

**R — Language Mechanics 011**, Occurrence and the Twenty-Eight-Seam Reader, standalone v0.2 (29 August 2026), §§1–3: write n=4c+p, retain occurrence o_n=(u,n), and take two consecutive four-phase cycles:

\[
W_c=\{o_{4(c+\ell)+p}:\ell\in\{0,1\},\ p\in\{0,1,2,3\}\},\qquad |W_c|=8.
\]

With a fixed run and initial point, the map from the ordinal address to the source engine state is

\[
o_{4c+p}\longmapsto(p,L_{\rm ax}^{c}z_0).
\]

The advancing axial coordinate separates cycles; phase separates the four members of each cycle. This composes the two cited constructions. No new clock law or continuous interpolation is presumed.

## 2. What is actually drawn

Eight distinct occurrence vertices give all 28 unordered pairs. The two-cycle partition gives

\[
E(K_8)=E(K_4^{(c)})\sqcup E(K_{4,4})\sqcup E(K_4^{(c+1)}),\qquad 28=6+16+6.
\]

Each diamond-like four-point layer in the technical drawing is the declared four-phase display of one cycle. Its four boundary links and two diagonals are six comparisons. All sixteen comparisons between cycles are also present. A pair-comparison edge does not claim a physical trajectory or a permitted transition of the escapement.

There are **eight** vertices. Joining two four-vertex diamonds at one vertex would instead leave seven distinct vertices. It would identify two occurrence addresses that this reader is designed to retain. In the supplied generated poster the bright shared-center diamond arrangement had that defect as an occurrence display.

### Declared display, with exact coordinates

For local lift index ell=0,1 and phase p=0,1,2,3, choose the diagram embedding

\[
v_{\ell,p}=(\cos(\pi p/2),\sin(\pi p/2),\ell).
\]

These are integer triples. The last coordinate is the normalized axial separation from cycle c, in units T. The display places four positions at each of two lift levels; its radius and spatial axes are conventions. It asserts no physical spatial metric.

The SVG uses the explicitly recorded rational oblique projection

\[
A=\begin{pmatrix}1&1/5&14/5\\1/7&1&3/5\end{pmatrix}.
\]

Eight different projected positions, no vertex lying inside an unrelated edge, all 28 lines, and all source matching colors were checked. Render rounding is separate from the exact rational coordinate record. Crossings carry no additional vertices.

The first trial projection put a vertex on an unrelated edge and was rejected by the collision test. The supplied projection passes that test. This correction changed only the display projection, not the carrier or incidence.

### What the dimensions count

- The source engine state is P4 × upper half-plane; on a fixed orbit its occurrences are discrete and unbounded.
- The window has eight addressed occurrences. Its free comparison carrier is E=R^8.
- A general alternating form on E has 28 independent coefficients: dim Λ²(E*)=28.
- The technical phase/lift display is an embedding in R^3, then a declared projection to the page. It is not an isometric representation of all of R^8.
- Under the *additional* scalar-potential rule d_ij=s_j-s_i, the allowed edge reads have dimension seven. The 56 triangle equations have rank 21. Thus 28 available coordinates does not imply 28 free values for every specialized reader.

## 3. Seven source matchings and the scan

Source R §6 relabels eight vertices by {infinity} union Z7. The actual supplied Four-Phase Addressing SVG assigns displayed vertex 7 to the distinguished infinity label and retains 0–6 as finite labels. This audit uses that same assignment.

\[
\mathsf M_a=\{\{\infty,a\}\}\cup\{\{a+j,a-j\}:j=1,2,3\},\quad a\in\mathbb Z_7.
\]

Every matching covers eight vertices in four disjoint pairs. Their disjoint union is all 28 edges. The label infinity here is a distinguished *combinatorial* address; it is not identified with the projective point [1:0] by the glyph alone.

The declared scan is q → (q mod 7,q mod 4) → edge. The inverse residue is q=8a+21b mod 28. The ledger records every mapping. The occurrence index n and scanner coordinate q remain separate; no new synchronization is supplied.

The accompanying program checks every edge and color directly against `four-phase-eight-state(2).svg`, rather than inferring a similar-looking pattern.

## 4. Return to the original double diamond

Source L, printed p.3 (PDF page 5), explicitly calls the double diamond **two proof compressions**. Its upper diamond constructs one carriage from the welded root reads. Its lower diamond separates the positive-projective and signed-Lorentzian reads, then joins their use at typed Contact/Recognition.

It is a dependency diagram. A curved sphere, lemniscate or two touching spatial diamonds does not follow from that page. The visual shape can guide a faithful redraw of its dependency arrows; it cannot supply new vertices, metric lengths or curves for the 28-seam carrier.

## 5. A separately checked link from the title mirror to the root

This section is an explicit calculation performed in this audit, not a quotation from the source.

Let G=[C1,Q]=[[-2,1],[1,2]], H=G/sqrt(5), and M=[[1,0],[1,-1]]. Set

\[
P=\begin{pmatrix}1&2+\sqrt5\\0&\sqrt5\end{pmatrix}.
\]

Exact algebra gives

\[
PHP^{-1}=M,\qquad
L_M=PL_{\rm ax}P^{-1}=\begin{pmatrix}1+\sqrt5&-2-\sqrt5\\1&-1\end{pmatrix},
\qquad ML_MM=L_M^{-1}.
\]

Thus the title's mirror can be related to the published root by an explicit invertible change of coordinates. The metric and other structures would also be transported when used in this chart. This is matrix conjugacy; it adds no unsupplied physical or perceptual interpretation. The independent central-lift identities (iM)^2=-I and (iM)^4=I are checked separately.

## 6. The actual publication frame

All five user-supplied published SVGs share these measured constants:

| Item | Source value |
|---|---|
| Canvas/viewBox | 800 × 1050 |
| Ground | #faf8f3 |
| Main title | centered at x=400, baseline y=143; Georgia/Times serif, 42; ink #262522 |
| Single-line subtitle variant | y=191, 18, opacity .65 (Independent Tunability) |
| Central diagram | center (400,560) |
| Two outer rings | radii 202 and 185; stroke #b38d4e, width 1 |
| Outer tick system | 28 ticks plus four cardinal extensions |
| Standard seven arcs | radius 175, width 6, opacity .7 |
| Equation | center exactly (400,836) in every reference |
| Author | (400,932), 11, letter spacing 2.2 |
| Imprint | (400,956), 9, letter spacing 1.7 |
| Footer face | Arial/Helvetica sans-serif, color #777065 |

The four thin-arc covers have **exactly matching 41-element frame prefixes**. Mirror Recognition uses the same outer frame with its seven filled four-slot sectors.

The source palette, clockwise from the top, is preserved in the JSON lock. The generated dark posters introduced a masthead, ring logo, R-series designation, right equation box, footer slogan and dense text absent from these five reference covers. Those drafts are excluded as style authorities.

`COPPALINI_COVER_FRAME.svg` contains the extracted source frame with empty diagram/equation slots. It is a reusable template, not a new cover proposal. The approved title/subtitle are recorded in `COPPALINI_COVER_STYLE_LOCK.json`.

## 7. Reproduction and boundary

Install `requirements.txt`, then run:

```sh
python verify_graph.py
python build_graph.py
```

The first command performs the 73 exact mathematical/incidence checks. The second performs the five-cover frame checks and produces the graph/reader from the verified coordinate and edge ledgers. The technical PDF was rendered and visually inspected. The reader's JavaScript passes `node --check`; its controls preserve the computed geometry and filter only the edges.

This closes the finite source-to-drawing audit described here. A Lean elaboration receipt for this new adapter/graph audit and a final publication-cover composition are not supplied by this bundle. The previous conversation's finite Lean results retain their own source and commit receipts.
