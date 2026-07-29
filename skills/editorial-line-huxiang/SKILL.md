---
name: editorial-line-huxiang
description: Create complete Huxiang-branded editorial line-art PNGs from text, URLs, images, products, UI concepts, campaigns, or articles. Use for Editorial line huxiang, 虎小象编辑线稿, 暖白纸张, 鼠尾草绿与陶土橙大地色系, or branded posters, infographics, story cards, social images, magazine spreads, website visuals, packaging, and image-to-illustration conversions that require image, exact visible copy, Huxiang-AI, page number, and the text-only @虎小象 signature to be designed together in one image-generation pass.
---

# Editorial Line Huxiang

把内容转译成虎小象专属的现代编辑线稿视觉：暖白纸张、克制墨线、鼠尾草绿与陶土橙为锚点的低饱和大地色系、内容驱动构图，以及固定品牌角标。

## Read first

Read [references/brand-contract.md](references/brand-contract.md) before generating. Treat its palette, lockup placement, text-only author rule, and safe zones as non-negotiable.

## Non-negotiable generation rule

Generate each final page with one `image_gen` call:

- Generate illustration, visible text, typography, layout, `Huxiang-AI`, page number, and the text-only `@虎小象` signature together.
- Do not generate a textless base for later typesetting.
- Do not use HTML, SVG, Pillow, Canvas, or a local overlay script to add visible content afterward unless the user explicitly requests a separate deterministic composition route.
- For a multi-page set, issue one complete `image_gen` call per page. Use an approved earlier page as a style reference when useful.

## Text-only author rule

- Render only exact text `@虎小象` at the fixed bottom-right position.
- Never draw, generate, upload, reference, or reserve space for an avatar, portrait, icon, circular photo, or author badge.
- Keep the signature small, muted, and secondary: approximately `24 px` at a 1080 px short edge.
- Do not use a capsule, ring, background pill, or shadow.
- Avatar treatments belong to HTML-based Huxiang skills and must not be mixed into this pure `image_gen` system.

## Visual DNA

- Draw clean, flat, geometric editorial line-art characters with simple expressive faces and stylized proportions.
- Translate ideas into recognizable actions, systems, tools, and everyday scenes rather than decorated text cards.
- Use warm-white paper, dark off-black ink, asymmetrical magazine hierarchy, intentional whitespace, and mobile-readable type.
- Use sage green and terracotta orange as the two palette anchors.
- Permit harmonized analogous earthy variants across clothing, props, packaging, interface surfaces, and icons:
  - sage side: eucalyptus, dusty moss, lichen, olive-gray;
  - terracotta side: clay, cinnamon, brick, muted apricot.
- Keep every accent medium-low saturation and similar in visual weight.
- Vary wardrobes across a series. Do not hard-code every character into a sage overshirt with a terracotta inner shirt.
- A character may wear sage, terracotta, or an approved analogous shade; use the second family on another garment, prop, or nearby interface accent to keep the set balanced.
- Keep skin and hair natural.
- Exclude neon, jewel tones, bright primary colors, cool blue, purple, glossy gradients, realistic lighting, 3D, anime styling, childish mascots, and decorative clutter.

## Workflow

1. Read or extract the source content.
2. Identify the core idea, emotional temperature, ordinary behavior, and proof of completion.
3. Choose the canvas:
   - vertical social page: `9:16`;
   - square card: `1:1`;
   - horizontal system board: `16:9`;
   - otherwise preserve the requested ratio.
4. Storyboard the content:
   - one idea: one dominant scene;
   - several clauses or steps: a content-shaped flow, system, or multi-panel sequence;
   - brand or product: show the behavior and application system that proves it exists.
5. Write the exact visible-copy list before generation. Keep copy detailed enough to teach, but large enough for phone reading.
6. Gather only main-subject or style references. Do not attach an author avatar.
7. Call `image_gen` once for the complete page.
8. Inspect the final rendered page at full size and thumbnail size.
9. Correct only one targeted problem per follow-up call.
10. Save every accepted final as a versioned PNG outside the generated-image cache.

## Input handling

### Text or URL

Preserve the source premise. Build a teaching hierarchy instead of translating line by line. Turn abstract concepts into scenes, flows, comparisons, or systems. Provide the exact visible Chinese copy inside the `image_gen` prompt.

### Image

Preserve the requested subject, pose, composition, and recognizable objects. Label every reference by role.

### Multi-page series

- Create a distinct content job for every page.
- Keep line weight, paper texture, typography character, brand positions, and saturation relationship consistent.
- Vary composition and wardrobe within the approved system.
- Pass an approved prior final as a style reference only. Do not pass an author avatar.

## Complete-page prompt template

Adapt this in English:

```text
Use case: infographic-diagram
Asset type: complete [RATIO] Huxiang editorial page
Input images:
- Image 1: [main/style reference role]

Primary request: Generate the COMPLETE FINAL PAGE in one image-generation pass. Illustration, all visible copy, typography, layout, Huxiang-AI, page number, and author lockup must be designed together. Do not return a textless base.

Scene: [CONCRETE SCENE OR SYSTEM]
Exact visible text—render verbatim and do not invent other copy:
[EXACT COPY LIST]

Visual system: warm off-white paper, clean off-black geometric line art, asymmetrical editorial hierarchy, mobile-readable typography. Use sage green and terracotta orange as anchors, plus only their muted earthy analogues such as eucalyptus, dusty moss, lichen, olive-gray, clay, cinnamon, brick, and muted apricot. Vary clothing naturally within this palette; do not repeat a fixed uniform.

Fixed lockups: Huxiang-AI top right; page badge bottom left; exact text @虎小象 at bottom right in small muted 24px-equivalent type. Do not draw, generate, upload, reference, or include any avatar, portrait, icon, circular photo, author badge, ring, capsule, or shadow.

Constraints: all exact text legible and inside the canvas; no gibberish, duplicated lines, invented statistics, fake case data, third color family, neon, blue-purple, gradients, 3D, photorealism, anime, childish mascot, or clutter.
```

## Composition rules

- Let the structure of the content determine the visual geometry.
- Avoid repeated equal cards and identical page templates.
- Use one dominant anchor, then attach explanations through asymmetric annotations, flows, or supporting scenes.
- Keep body copy comfortably readable on a phone. Do not create tiny decorative paragraphs.
- Use the expanded earthy palette to create variety while keeping the set recognizably Huxiang.
- Keep critical content away from the fixed lockup safe zones.

## Output and quality gate

Default deliverable: complete branded PNG files, not only prompts or art direction.

Reject or revise a page if any answer is “no”:

- Were text, image, typography, brand, page, and author generated together in one `image_gen` call?
- Does the page teach through a real scene, system, flow, or comparison?
- Is every required string readable and spelled correctly?
- Is the background warm paper with off-black linework?
- Are colors limited to the harmonized sage–terracotta earthy system?
- Do garments vary naturally instead of repeating one fixed sage outfit?
- Is `Huxiang-AI` fixed at top right and the page badge fixed at bottom left?
- Is the bottom-right `@虎小象` text quiet and proportional?
- Is the page completely free of avatars, portraits, circular author photos, and author icons?
- Is the page free of invented statistics, fake case data, gibberish, overlap, and clipped text?
- Was the final PNG itself inspected rather than inferred from a tool response?
