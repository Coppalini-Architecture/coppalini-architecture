# Coppalini Architecture Site Style Guide

## Publication date

Adopted: `2026-11-10`

Every homepage post carries a visible publication line and a machine-readable
HTML `<time>` element.

```html
<time class="publication-stamp" datetime="YYYY-MM-DD">
  DD Month YYYY
</time>
```

- The visible line sits on its own line beneath the entry&rsquo;s category or series line.
- The public surface uses one date format throughout: `DD MONTH YYYY`.
- The `datetime` value records the source-backed date in ISO 8601 form.
- A release receipt may retain a finer ISO timestamp when one exists; it does not change the uniform public date line.
- Historical entries retain the finest date resolution carried by their source record.

## Four-form result lines

Each equation-tethered result line carries a narrow, distinct color rule. The
rule distinguishes the four offices while preserving the shared neutral paper
field:

| Form | Accent |
| --- | --- |
| Gravity&ndash;Light | gold |
| Memory&ndash;Motion | green |
| Time&ndash;Scope | blue |
| Horizon&ndash;Silence | violet |

Each source citation is a direct link to the corresponding form.

## Metric Minimum public-copy admission

Field copy begins with its jurisdiction: the declared carrier, native
equation, condition, source coordinate, and result status. The first public
sentence names the field relation before any finite chart, compiler, verifier,
or release material.

Every public technical word is admitted through one complete record:

\[
\text{ordinary handle}
\;\longrightarrow\;
\text{typed map } f:A\to B
\;\longrightarrow\;
\text{invariant or named condition}
\;\longrightarrow\;
\text{native source coordinate}
\;\longrightarrow\;
\text{status / receipt}.
\]

No public opening may substitute a container phrase for that record. In
particular, “exact” must name the equation or theorem that is exact; “finite”
must name its carrier and physical office; and a field reference must name the
field, its carrier, and the map by which it enters the stated result. The
phrases “an exact operational closure,” “a finite root,” and “field-facing”
carry no public meaning by themselves.

The first screen answers, in this order:

1. What source equation or construction is being reported.
2. What map it fixes and what the map carries.
3. What theorem, reduction, or finite identity has been established.
4. Which source, compiler run, or independent check carries that strength.
5. What a reader can now inspect or compute directly.

Use the reference edition’s seven status words literally:

| Status | Public meaning |
| --- | --- |
| Exact finite | An algebraic identity checked in the declared finite carrier. |
| Exact derived | An exact consequence of displayed identities or a stated construction. |
| Lean-checked | A statement at the pinned Lean source with its stated audit record. |
| Conditional | A statement whose named premises remain part of its result. |
| Source declaration | A typed carrier, boundary, or partial map retained at its cited source. |
| Interface | A declared map between carriers or readers. |
| Candidate | A next construction with its test stated. |

`Cited`, `source-documented classical mathematics`, `negative control`, and
`open item` are evidence descriptors or boundary conditions, not additional
result statuses. The canonical public crosswalk lives at
`/papers/symmetric-minimum/#status-lineage`.

The Metric Minimum page keeps four source offices visible and separate in its
opening order:

1. P13 / Suture Field: \(\Pi^A{}_\mu\), \(g=h(\Pi)\),
   \(F=f(\Pi)\), and the regular branch.
2. Canonical Einstein--Maxwell: \((\gamma,\pi;A,E)\), one bracket,
   \(G,D,H\), and the seven-premise bracket theorem.
3. Symmetric Minimum: the finite carrier \(V=\mathbb R^2\) with
   \(Q,J,H,G,L_s\).
4. P14: the declared continuum sequence between those records.

Every display receives a local key before use. Every paragraph ends at a direct
source route. A historic name enters public copy only with its source row.
