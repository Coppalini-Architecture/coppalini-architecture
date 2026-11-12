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
