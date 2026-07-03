# Huxiang Fashion Prompt Style System

## Method In One Sentence

First lock the non-negotiable subject inputs, then randomize only the replaceable scene variables through controlled matrices, then block common model failure modes with anti-collapse rules and a final quality gate.

## What Makes This Style Work

- It treats references as authorities, not inspiration.
- It gives the model specific photographic physics: lens, light, wind, exposure, depth, and motion.
- It creates variation with matrices instead of vague requests for creativity.
- It prevents lazy defaults by naming the most likely bad result.
- It checks coherence before final output: action, space, light, props, outfit readability, body proportion, and mood must agree.

## Authority Locks

Use direct priority language:

```text
OUTFIT_REF is REQUIRED and is the absolute wardrobe authority.
Reproduce garment type, silhouette, color, fabric, texture, pattern, layering, structure, fit, proportions, footwear, and styling elements with 100% fidelity.
No substitutions, no simplification, no redesign, no invented styling.

FACE_REF is OPTIONAL.
If FACE_REF is provided, it becomes the absolute identity authority: match facial structure, proportions, skin texture, hairstyle, and overall identity exactly with zero drift.
If FACE_REF is not provided, use the default identity specified below.

If any written clothing or identity description conflicts with the uploaded reference, the uploaded reference always wins.
```

When the user's request is not clothing-reference based, replace `OUTFIT_REF` with the real authority, such as `PRODUCT_REF`, `LOCATION_REF`, or `MOODBOARD_REF`.

## Default Identity Pattern

Use a default only when the user has not supplied a face reference and still needs a fashion subject:

```text
If FACE_REF is NOT provided, use a tall, slender East Asian woman with elegant dimensional facial features, clear bone structure, refined natural proportions, realistic skin texture, naturally textured medium-length hair, and a calm premium fashion presence.
Her facial features must not become flat, generic, childish, overly cute, overly Westernized, celebrity-like, or identity-inconsistent.
Her medium-length hair must remain naturally textured and wind-aware: visible strands and ends respond to the same believable airflow as the outfit and scene, without covering the face or weakening identity readability.
```

Adjust identity respectfully when the user specifies age, gender, ethnicity, body type, or brand model direction. Never over-describe ethnicity or beauty traits when they are not needed.

## Photographic Spine

Choose one concrete camera language:

- `Authentic iPhone native-camera feeling, main wide lens around 24-28mm equivalent, natural exposure, realistic white balance, no Portrait mode blur.`
- `Humanistic 35mm documentary street perspective with Fujifilm film simulation, soft highlight roll-off, gentle contrast, slightly warm tones, fine natural grain.`
- `Premium real-life frame captured in passing by a stylish friend, slight handheld imperfection, candid timing, not a staged campaign.`

Avoid mixing incompatible camera claims. Do not request iPhone native and DSLR compression in the same prompt.

## Matrix Design

Build matrices from variables that can change without breaking the user's core idea.

Useful matrix categories:

- Action or pose.
- Scene/world family.
- Scene detail zone.
- Light behavior.
- Wind or motion behavior.
- Foreground or occlusion layer.
- Camera position.
- Head direction and eye line.
- Prop/accessory interaction.
- Background social layer.
- Material and color atmosphere.

Matrix rules:

```text
The model must internally shuffle and select EXACTLY ONE option from each matrix.
Do not ask the user to choose.
Do not render matrix labels, option numbers, placeholders, brackets, variables, or alternative choices into the final image.
Do not default to the first-listed option, the safest option, or the most generic option by habit.
If two selected items feel repetitive, weak, incompatible, or too generic together, replace only that one item once, then lock the full set again.
```

Long-form prompts may include visible matrix headings such as `ACTION MATRIX` or `SUNLIGHT MATRIX`; this is part of the user's established style. The prohibition is against the generated image containing prompt text, labels, option numbers, or menu artifacts.

## Batch Gaze Diversity

When generating a set, grid, series, or multiple variations with visible faces, always add a dedicated head-direction and eye-line matrix. Varying camera position is not enough; models often change the lens angle while keeping every face turned toward image-right.

Use this batch rule:

```text
If generating a set or batch, visible face direction must vary across the set.
Do not make every subject look toward image-right.
Across 9 images, use at least 5 distinct head-and-gaze directions.
No more than 2 images may share the same head direction or eye direction.
Camera angle, body direction, head turn, and eye line must not collapse into the same right-facing three-quarter profile.
```

Use this matrix when the user asks for a set or when the prompt may be reused for multiple outputs:

```text
GAZE AND HEAD DIRECTION MATRIX
Internally select EXACTLY ONE option for each image, and rotate options across the batch:
1. looking directly into the camera with a calm candid expression
2. looking slightly left of camera, three-quarter face visible
3. looking slightly right of camera, three-quarter face visible
4. looking down at the object, garment detail, or scene detail in her hands
5. looking toward the light, wind, or architectural direction, face lifted naturally
6. looking over her shoulder back toward the camera
7. looking toward the open distance, side profile, alternating left and right across the batch
8. eyes lowered softly while the head turns toward camera, quiet candid moment
9. looking toward a person or action off-camera, not toward image-right by default
```

Add a matching negative when relevant:

```text
No repeated right-facing gaze across the batch.
No every-subject-looking-to-image-right collapse.
No identical head angle repeated across all images.
```

For complex systems, use staged selection:

```text
Stage 1: Privately select EXACTLY ONE action family first and lock it.
Stage 2: Privately select EXACTLY ONE scene/world family compatible with the action and lock it.
Stage 3: Privately select EXACTLY ONE option from each remaining matrix.
Run a coherence check before writing the final prompt.
```

## Matrix Option Quality

Good options are concrete and spatial:

- `walking out of the cafe holding takeaway coffee, just past the threshold`
- `fragmented sunlight falling between tall buildings, creating broken patches on the road`
- `glass reflection layer partially crossing the subject`
- `cave-mouth daylight fading from bright exterior to cool interior stone shadow`

Weak options are generic:

- `beautiful cafe`
- `nice light`
- `stylish pose`
- `cinematic background`

When possible, include spatial relationships: through a gap, beyond a railing, at a threshold, reflected in glass, behind a facade, between parked cars, under a colonnade.

## Anti-Collapse Rules

Write anti-collapse rules for the specific prompt domain. Examples:

```text
Do not collapse into the default safe answer of "woman sitting quietly by a wooden cafe window."
If the selected action is standing, ordering, walking, waiting, chatting, or picking up coffee, the image must remain standing, transitional, or active.
Do not turn the partial sea glimpse into a full beach scene or resort postcard.
Do not reduce the cave, waterfall, greenhouse, courtyard, roastery, gallery, terrace, or heritage setting to a generic beige cafe background.
No tourist-landmark framing; the street must feel real, clean, and lived-in.
```

Name the failure directly. The point is to stop the image model from using its most common template.

## Light, Wind, And Motion

Light must be directional and consistent:

- Morning low-angle sunlight.
- Warm late-afternoon back-side sunlight.
- Fragmented light between tall buildings.
- Reflected light from pavement, water, stone, or car windows.
- Cave-mouth or threshold daylight.
- Real lens flare only when requested.

Wind must have one believable source:

```text
Wind dynamics are mandatory.
Naturally textured medium-length hair must show visible natural movement.
Several strands of hair should drift naturally across the face without hiding identity.
Outfit edges, hems, collars, sleeves, or loose structural areas should respond subtly to the same breeze.
If indoors, airflow should feel believable from an open door, window gap, corridor draft, courtyard opening, cave mouth, skylight shaft, terrace edge, or semi-outdoor threshold.
Motion must feel real, gentle, and unforced.
```

## Composition And Body Read

Use camera and posture to create elegance, not anatomy distortion:

```text
The subject is always the hero.
Outfit readability must remain clear.
Foreground adds depth but must not block the face.
Use a slightly low-angle full-body frame only when it helps create a tall, long-leg impression naturally.
The body should feel elongated because of posture, lens position, silhouette clarity, and line of movement, never because of anatomical stretching.
```

## Negative Prompt Pattern

Use strict, domain-relevant negatives:

```text
No deviation from OUTFIT_REF.
No face drift if FACE_REF is provided.
No age change, ethnicity change, beautification drift, or identity reinterpretation.
No studio lighting rigs.
No fake cinematic LUT.
No Portrait mode blur unless requested.
No DSLR compression when iPhone native camera is requested.
No heavy beauty filters, plastic skin, or AI-smoothed texture.
No distorted hands, face, limbs, or body proportions.
No cluttered tourist background or cheap visual noise.
No loud logos, brand marks, watermarks, or readable random text.
No foreground, crowd, prop, or reflection blocking the face or outfit.
```

## Final Quality Gate

Before returning the prompt, verify:

- The output asks for one image only.
- Input locks are written before creative scene description.
- References override conflicting text.
- If no FACE_REF is provided, the East Asian default identity fallback is present: dimensional facial features, clear bone structure, tall slender frame, realistic skin texture, naturally textured medium-length hair, and wind-aware hair movement.
- Every matrix has an exact-one selection rule.
- For a set or batch with visible faces, head direction and eye line have their own diversity rule and matrix.
- Any matrix labels and option numbers are prompt instructions only and must not appear as image text.
- The scene world has specific spatial identity.
- Light direction, wind, action, props, and environment are physically compatible.
- Outfit and face remain readable.
- The anti-collapse rule names the likely failure mode.
- Negative constraints are specific and not a generic word dump.
