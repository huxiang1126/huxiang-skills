# Huxiang brand contract

Apply this contract to every Editorial line huxiang artifact.

## Paper and ink

| Role | Hex | Use |
|---|---:|---|
| Warm paper | `#F4EFE6` | Main field |
| Ink | `#252522` | Lines and primary type |
| Muted ink | `#5C5953` | Secondary type and author |

Warm paper and negative space must dominate. Never use pure black.

## Earthy accent system

Sage green and terracotta orange are palette anchors, not fixed uniforms.

| Family | Light | Base | Dark | Approved analogues |
|---|---:|---:|---:|---|
| Sage | `#D7E0D2` | `#8FA58A` | `#657763` | eucalyptus `#A7B39B`, dusty moss `#7C8B70`, lichen `#B7B99F`, olive-gray `#777B68` |
| Terracotta | `#E8C1AD` | `#C66F4E` | `#98513B` | clay `#B96F54`, cinnamon `#A65F46`, brick `#8E4D3A`, muted apricot `#D79A78` |

Rules:

- Keep every accent muted, earthy, medium-low saturation, and similar in visual weight.
- Use approved analogues on clothing, props, packaging, UI surfaces, and icons.
- Vary clothing across a set. Do not repeat one mandatory sage jacket and terracotta inner shirt.
- Balance the two sides across the full page or series; a single garment may lead with either family.
- Keep skin and hair natural.
- Exclude cool blue, purple, neon, jewel tones, and bright primary colors.

## Fixed lockups

Scale from the short canvas edge.

### Brand tag

- Anchor: top right.
- Inset: `5.6%` from right and `3.3%` from top.
- Sage-filled rounded rectangle, no shadow.
- Exact text: `Huxiang-AI`, warm paper, medium-weight sans serif.
- Reference at 1080 px short edge: `220 × 56 px`, `16 px` radius, `28 px` type.

### Page badge

- Anchor: bottom left.
- Inset: `5.6%` from left and `2.8%` from bottom.
- Terracotta-filled rounded rectangle, no shadow.
- Exact text: two-digit page and total, such as `01 / 09`.
- Warm-paper tabular or monospaced numerals.
- Reference at 1080 px short edge: `132 × 52 px`, `14 px` radius, `22 px` type.

### Author lockup

Anchor at bottom right, inset `5.6%` from right and `2.8%` from bottom.

- Render only exact text `@虎小象`.
- Use muted `24 px` sans-serif type at a 1080 px short edge.
- Keep the signature quiet and secondary.
- Use no avatar, portrait, icon, circular photo, ring, capsule, badge, background pill, or shadow.
- Do not attach an avatar reference to `image_gen`.
- Avatar treatments belong to HTML-based Huxiang skills and must not enter this pure `image_gen` system.

## Safe zones

Keep headlines, captions, faces, hands, products, and critical props outside:

- top-right: rightmost `31%` × top `10%`;
- bottom-left: leftmost `23%` × bottom `9%`;
- bottom-right: rightmost `28%` × bottom `8%`.

Quiet paper texture or nonessential linework may enter these zones if readability remains clear.

## Single-pass contract

For each final page, make one `image_gen` call that includes:

- illustration;
- all visible copy and typography;
- brand tag;
- page badge;
- text-only author signature.

Do not create a textless base and do not add visible content through deterministic post-processing unless the user explicitly requests that separate route.

## Final verification

Inspect the finished PNG and confirm:

- all required strings are present and legible;
- `Huxiang-AI`, page number, and `@虎小象` are exact;
- no lockup is cropped or dominant;
- no avatar, portrait, circular author photo, or author icon appears;
- wardrobe colors vary within the approved earthy system;
- no cool or high-saturation color has entered;
- no fabricated statistics, fake case data, gibberish, repeated lines, or accidental extra labels appear.
