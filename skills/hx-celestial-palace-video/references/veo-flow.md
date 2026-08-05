# Google Flow / Veo Operating Procedure

This procedure captures the failure modes seen in prior browser-driven production. The UI is allowed to change; visible current state always outranks remembered labels or coordinates.

## Route selection

1. Look for an already available, authenticated official connector, API, or CLI that supports the user's actual Flow/Veo subscription and image-driven generation.
2. If none exists, load `chrome:control-chrome` and reuse the user's signed-in Chrome session.
3. Use `computer-use:computer-use` only for native macOS dialogs or UI surfaces that Chrome control cannot access.
4. Do not invent an API key path, start a billable cloud project, or switch the user's subscription to API billing.

Chrome is the normal route for consumer Flow subscriptions because authentication, model availability, credits, and downloads are session-bound.

## Fresh-state rule

- Inspect the current browser tab and accessibility/UI state before every consequential selection.
- Prefer element-based actions to coordinates.
- After a mode change, upload, or generation, inspect the state again. Do not reuse stale element indices or remembered screen positions.
- If accessibility text is incomplete, inspect a screenshot before clicking by coordinates.

## Select the correct input mode

For this Skill:

1. Select `视频`.
2. Select `素材` for image-driven generation.
3. Use `帧` only for a deliberate first/last-frame workflow. It is a different mode, not a substitute for `素材`.
4. Upload `stills/clean/S##_clean.png`, never the watermarked still.

Confirm that the uploaded thumbnail is the correct shot before entering the prompt.

## Model and duration

- Prefer the user's requested visible label, commonly “Veo 3.1 Lite,” when it is present.
- Record the exact displayed label because names and availability may drift.
- Choose only a duration shown in the current UI. A typical plan is 6 seconds for most shots and 8 seconds for two hero shots, but do not force unsupported values.
- Do not silently switch to a more expensive model or consume materially more credits.

## Prompt input reliability

Some web apps update their generation state only after real input events. A pasted or programmatically set value can look present while the generation button remains gray.

Recovery:

1. Focus the prompt field.
2. Select all and delete.
3. Enter the prompt using keyboard-style typing (`type_text`) rather than value injection or clipboard paste.
4. Inspect the fresh UI state.
5. Proceed only when the generation button is visibly enabled.

If it remains gray, check uploaded-media state, required mode, model, duration, credit/error messages, and whether the prompt field actually retained text. Do not repeatedly click the disabled button.

## Native file picker

File uploads may open a native macOS picker that browser automation cannot inspect.

1. Load `computer-use:computer-use`.
2. Inspect the picker state.
3. Use the explicit clean image path from the manifest.
4. Confirm the filename before choosing Open.
5. Return to Chrome control and verify the thumbnail.

File upload is externally transmitting the selected image. The user's instruction to generate the video with Flow pre-authorizes those exact production stills, but not unrelated files.

## Motion prompt pattern

Keep the prompt short and image-specific:

```text
Preserve the original architecture, scale, composition, moon position, costume, and character identity. Slow cinematic motion only. The camera gently tracks [left/right] with no orbit and no rapid zoom. The rear-view figure walks naturally and slowly [or remains still]. Hair, one or two garment panels, and [cloudfall/waterfall/banner/pine needles] move softly in one consistent high-altitude breeze. Real gravity and stable geometry. Environmental sound effects only: soft wind, distant water, light fabric movement; no music, no speech. No cut, no new buildings, no railing, no text, no logo, no watermark, no face turn, no body or costume morphing.
```

Adapt only the bracketed subject and phenomenon. One shot gets one clear camera action, one figure action, and one environmental movement.

## Acceptance gate

Download and inspect the actual clip. Reject when any of these occur:

- architecture bends, breathes, duplicates, or sprouts new structures;
- a railing appears;
- moon, column, gate, or platform scale changes materially;
- the person morphs, faces camera unexpectedly, slides, floats, or gains limb/fabric artifacts;
- garments move in conflicting directions or behave like smoke;
- the camera orbits, whips, crash-zooms, or cuts;
- clouds cover the platform and feet;
- generated music, speech, captions, or logo appears;
- no meaningful motion is visible after download.

## Download evidence chain

Before clicking Download, record the time and snapshot the download directory. Afterward:

1. Identify a file created after that time; do not select an older same-named clip.
2. Wait until browser temporary suffixes disappear and the byte size remains stable across two checks.
3. Run `ffprobe` to verify a decodable video stream, nonzero duration, dimensions, and frame rate.
4. Calculate SHA-256 and record it with shot ID, visible model label, UI duration, prompt, attempt number, and download time.
5. Move it immediately to `clips/raw/S##_attempt##.mp4` using an absolute path.
6. Inspect that exact local file. Only an accepted clip is copied or moved to `clips/accepted/S##_veo.mp4`.

Keep failed attempts in `clips/raw/` with rejection notes. Put only the accepted version in `clips/accepted/`.

## Human handoff conditions

Ask the user to take over for CAPTCHA, credentials, new legal terms, security warnings, or a purchase/credit action outside the already authorized plan. Resume from the fresh UI state after handoff.
