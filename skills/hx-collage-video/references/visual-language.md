# Visual language

## Visual signature

- Flat, bold, uniform paper color field
- Black-and-white halftone photographic cut-outs
- Selective colored cardstock accents
- Crisp machine-cut edges
- Thin warm-cream keylines
- Soft, low-opacity paper shadows
- Fine uncoated paper grain
- Locked vertical poster composition with generous negative space

The frame should feel printed, cut and physically arranged, not rendered as a glossy 3D scene.

The style can be built either as a finished generated frame or as a layered edit. A finished poster is not automatically the best production asset: when people and objects need independent timing, generate isolated cut-outs and assemble them on one controlled paper canvas.

## Color semantics

- Burnt orange / red: labor, time pressure, urgency
- Mustard yellow: tools, warning, leakage
- Ink green: cognition, taste, system reset
- Deep purple: rules, codification, long-term memory
- Teal: judgment, cooperation, autonomous execution
- Cream: neutral structure, pause, human warmth

Use color to encode meaning. Do not color every object.

## Visual spec template

```json
{
  "script_meaning": "",
  "emotion": "",
  "visual_metaphor": "",
  "style_signature": "flat bold color field, black-and-white halftone cut-outs, selective colored cardstock, cream keylines, soft paper shadows, editorial paper collage",
  "aspect_ratio": "9:16",
  "color_field": {
    "background_hex": "",
    "accent_colors": [],
    "paper_grain": "fine uncoated-paper fiber"
  },
  "elements": [
    {
      "what": "",
      "role": "",
      "placement": "",
      "assembly_motion": ""
    }
  ],
  "composition": {
    "layout": "",
    "negative_space": "",
    "final_frame": ""
  },
  "assembly_order": [],
  "avoid": "typography, letters, numerals, logos, watermark, UI, subtitles, glossy 3D, photoreal environment"
}
```

## Codex image prompt template

Rewrite this into one coherent prompt. Do not paste it mechanically.

```text
Create a finished vertical 9:16 editorial paper-collage still expressing [VISUAL PROPOSITION].

Use a perfectly flat [COLOR NAME] paper field ([HEX]) with subtle uncoated paper fiber. Build the subject from black-and-white halftone photographic cut-outs with selective [ACCENTS] colored cardstock. Every piece has crisp machine-cut edges, a thin warm-cream paper keyline and a soft low-opacity physical paper shadow.

Locked poster framing. Keep the central subject inside the middle 70 percent, with generous clean negative space. Use only 3–6 large separable paper groups so the scene can later assemble piece by piece. The relationship [CORE RELATIONSHIP] must be readable at a glance.

No typography, no readable letters, no numerals, no logos, no watermark, no UI, no subtitles, no glossy 3D, no photoreal environment, no clutter. Do not add decorative objects that do not carry meaning.
```

## Transparent layer prompt

Use this route for `timeline_collage` elements:

```text
Create one isolated editorial paper-collage cut-out of [SUBJECT PERFORMING A VISIBLE ACTION].

The complete subject and every held object must fit inside the frame with generous transparent padding. Black-and-white halftone photographic paper, selective [ACCENT] cardstock, crisp machine-cut edge, thin warm-cream keyline, soft low-opacity paper shadow. Front or clear three-quarter silhouette chosen for action legibility.

True transparent RGBA background. No backdrop, floor, frame, rectangle, checkerboard pattern, text, letters, numbers, logo, watermark, UI, extra people or detached duplicate limbs.
```

After generation, inspect the actual alpha channel. If the file has an opaque background, isolate it before assembly and store the repaired file as a new version. Do not rename an opaque image to `.png` and call it transparent.

## Anti-fake-lettering rules

- Clock, gauge or dial: plain tick marks only; no digits and no Roman numerals
- Sleeping figure: no `Zzz`
- Cards and books: blank fields or abstract bars only
- Screen-like object: no interface, fake menu or icon grid
- Never place the original spoken sentence in the frame

## Human legibility rules

- A named role must be identifiable from clothing, tool, setting, relationship, and action; do not rely on a tiny face or caption to explain it.
- Primary human actions should occupy roughly 20% or more of the useful frame area and remain continuously readable for at least 1.5 seconds in the final master.
- Secondary social context should remain readable for at least 1.0 second and must not be hidden by hard subtitles.
- A static lineup, cast sheet, distant silhouette, or crowd texture is not a substitute for an action beat.
- Do not place all working people at the bottom edge as scale references while monuments and symbols dominate the frame.
- When a system metaphor occupies one beat, follow it with a human-scale beat unless the omission is deliberate and documented.
- Evaluate these rules on the rendered MP4. Passing keyframes or source assets is not enough.
- A moving transparent PNG is an editing primitive, not automatic proof of action. Use pose changes, separated props, masks or a short generated inset when a verb cannot be read from translation alone.

## Direct assembly motion prompt

```text
Locked-off vertical 9:16 paper-collage stop-motion assembly. Image 1 is the exact empty first frame. Image 2 is the exact approved completed last frame.

Open on the empty flat [COLOR] paper field. Assemble the scene piece by piece with crisp physical stop-motion timing: [ORDERED MOTION PLAN]. Each group slides in or snaps into place separately. End by landing exactly on and holding the supplied completed composition.

Preserve the color field, halftone dots, colored cardstock accents, paper grain, cream keylines, crisp cut edges and soft shadows. Restrained tactile 2D paper craft only.

No cuts, no camera movement, no zoom, no morphing, no new objects, no text, no letters, no numbers, no logo, no watermark, no UI, no sound.
```

## Reverse-disassembly motion prompt

```text
Locked-off vertical 9:16 paper-collage stop-motion disassembly. Begin from this exact completed reference image and preserve its composition.

Disassemble the paper scene piece by piece in this exact reverse order: [REVERSE ORDER]. Each paper group slides cleanly out of frame or lifts away with crisp physical stop-motion timing. The final state must be a completely empty, perfectly uniform [COLOR] paper field matching the original background.

Preserve the 2D halftone paper style until each piece exits. No cuts, no camera movement, no zoom, no global fade, no morphing, no new objects, no text, no letters, no numbers, no logo, no watermark, no UI, no sound. End on the empty paper field and hold it.
```
