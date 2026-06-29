---
name: huxiang-fashion-prompt
description: Build production-ready photorealistic candid fashion image prompts in the user's matrix-driven style. Use when the user asks Codex to write, improve, or systematize image-generation prompts for fashion, AMASS outfits, street style, cafe scenes, iPhone/Fujifilm documentary looks, OUTFIT_REF/FACE_REF identity locks, random prompt matrices, anti-collapse rules, or photorealistic lifestyle fashion images.
---

# Huxiang Fashion Prompt

## Overview

Use this skill to turn the user's rough fashion-image idea into a complete image prompt that follows their established style: lock the non-negotiable identity/outfit inputs first, matrix the variable scene choices, then add anti-collapse rules and a quality gate so the model cannot drift into generic fashion imagery.

Default to producing one copy-pasteable final prompt. Ask a question only when the missing detail changes the whole prompt direction; otherwise make a conservative choice and include replaceable reference names such as `OUTFIT_REF` and `FACE_REF`.

## Core Workflow

1. Extract the user's intent:
   - Subject, outfit/reference requirements, face/reference requirements.
   - Setting world, mood, season, location, brand context, camera language.
   - Must-have objects, action, light, wind, props, body read, and forbidden outcomes.
2. Establish authority locks before any scene writing:
   - `OUTFIT_REF` is the wardrobe authority when clothing fidelity matters.
   - `FACE_REF` is optional by default, but becomes the identity authority when provided.
   - If no `FACE_REF` is provided, define a restrained default identity only if the user needs one.
   - State that reference images override conflicting text.
3. Define the photographic spine:
   - One image only.
   - Photorealistic candid fashion image, not a studio campaign.
   - Use a concrete camera surface such as iPhone native camera, Fujifilm film simulation, 24-28mm main lens, 35mm documentary feel, natural exposure, mild highlight roll-off, realistic white balance, fine grain.
4. Add physical realism:
   - Natural sunlight or a specific light source must be present.
   - Wind and motion should share one believable cause.
   - Hair, garment edges, light props, and body movement should respond consistently.
5. Build randomization matrices only for replaceable variables:
   - Typical matrices: action, scene/world, light, foreground, camera position, prop/accessory, background social layer, material/color atmosphere.
   - Each matrix should offer specific, visually different options.
   - Require exactly one option per matrix, internal shuffle, no first-option bias, no exposed labels in the final image.
6. Add anti-collapse rules:
   - Name the default failure mode directly, for example generic cafe window seating, tourist landmark street, beach postcard, beige interior, fake luxury set, overposed fashion campaign.
   - Preserve the chosen action and scene world; do not let the final prompt rewrite an active scene into a seated pose.
7. Add composition rules and a quality gate:
   - Subject remains the hero.
   - Outfit is readable.
   - Foreground adds depth but never covers face or outfit.
   - Space is specific, not generic.
   - Camera and body proportions create elegance without anatomical distortion.
8. Finish with strict negative constraints:
   - Use specific high-risk negatives, not a generic low-quality word dump.
   - Always include no identity drift, no outfit drift, no plastic skin, no unreadable anatomy, no random logos/watermarks, no readable accidental text unless requested.

## Output Shape

For most user requests, output:

1. A concise Chinese note explaining the chosen direction if useful.
2. The final prompt in English, because most image models follow this style more reliably in English.
3. Optional short variants only if the user asks for alternatives.

The final prompt should be a complete prompt, not a plan. It may include matrix section names when writing a prompt in the user's long-form style. The important constraint is that the image model must not render labels, option numbers, placeholders, brackets, variables, or menu text into the image. Do not ask the user to choose from matrices unless the user explicitly asks to co-design the system.

## Prompt Sections

Use this section order for full prompts:

1. Role or generation target.
2. Required inputs.
3. Identity and outfit lock.
4. Core mood and photographic look.
5. Light, wind, and motion.
6. Environment or world definition.
7. Hidden selection protocol.
8. Matrices.
9. Composition rules.
10. Final render directive.
11. Negative prompt.

For shorter prompts, keep the same priority order even if sections are compressed.

## Reference

Read `references/style-system.md` when constructing a longer prompt, when the user asks to preserve their exact method, or when you need matrix examples, anti-collapse patterns, and quality checks.
