---
name: hx-celestial-palace-video
description: "Create a complete nine-shot 9:16 Chinese celestial-palace visual film: generate nine independent stills with imagegen, animate clean first frames in Google Flow/Veo through Chrome when no stable direct route exists, add the bundled user-supplied music and watermark, assemble in HyperFrames, and inspect the final MP4. Use for 天宫、仙界、云上海宫、东方仙侠建筑、巨物尺度或同类无旁白氛围短片 production."
---

# HX Celestial Palace Video

Produce an actual inspected vertical film, not only prompts or a storyboard. Preserve the supplied celestial world while varying scale, architecture, distance, motion, foreground, and spatial rhythm across nine independent shots.

## Non-negotiable contract

- Deliver exactly nine independent 9:16 source still files. A contact sheet or 3×3 grid does not count.
- Generate every still with the built-in `imagegen` capability. Form one shared world bible and nine distinct scene relations before generating.
- Keep a clean, unwatermarked still master for every shot. Send only clean masters to Veo.
- Animate through Google Flow using the image-driven `素材` mode. Use `帧` only when the task explicitly calls for first/last-frame animation.
- Veo clips contain environmental sound effects only: no generated music and no speech unless the user explicitly requests it.
- Use the bundled music only in final editing, cut to the finished duration. Do not loop it by default.
- Add the bundled watermark to still deliverables and as a fixed final-composite layer. Never ask Veo to regenerate a watermark.
- Finish in HyperFrames at 1080×1920, 30 fps, then inspect the rendered MP4 and sampled frames before claiming completion.
- Do not stop at a plan when the user asks for a finished video. Continue through generation, download, edit, render, and QA unless a real authentication, payment, or content-policy blocker requires the user.

## Required companion skills

Load only when that stage begins:

- Still generation: `imagegen`.
- Google Flow/Veo in a signed-in browser: `chrome:control-chrome`.
- Native macOS file picker or inaccessible browser control: `computer-use:computer-use`.
- Final edit: `hyperframes`, `hyperframes-core`, `hyperframes-animation`, `hyperframes-cli`, and `media-use`.
- GitHub publishing is not part of ordinary video production; use the GitHub publishing skill only when the user asks to change or publish this Skill.

Prefer a stable direct API, connector, or CLI when it is already authenticated and clearly supports the user's Flow/Veo entitlement. Otherwise reuse the user's signed-in Chrome session. Never create credentials, start a paid API project, change billing, or accept new terms as an unannounced workaround.

At the start of execution, resolve `SKILL_DIR` to the absolute directory containing this loaded `SKILL.md`. All bundled script and asset references below mean `"$SKILL_DIR/scripts/..."` and `"$SKILL_DIR/assets/..."`; never assume the project working directory is the Skill directory. Use absolute paths for project inputs and outputs.

## Stage 0 — Establish the production contract

Create `production-manifest.md` with:

- output directory and intended final filename;
- nine shot IDs (`S01`–`S09`), target durations, and total target duration;
- the visible Flow model label and visible duration choices when inspected;
- clean still, watermarked still, source clip, and accepted clip paths;
- music source, authorization note, trim duration, and loudness treatment;
- watermark asset, placement override if any, and reason;
- generation attempts, rejection reasons, and final acceptance state.

Default to a 54–62 second visual film when all nine shots are used. A useful starting rhythm is seven 6-second clips plus two 8-second hero clips, adjusted to the actual UI choices and musical phrases.

## Stage 1 — Design nine relationships before rendering

Read [references/world-bible.md](references/world-bible.md) and [references/nine-shot-matrix.md](references/nine-shot-matrix.md).

Build the nine-row matrix before the first image call. Adjacent rows must change at least four of these axes: main giant structure, figure scale, rear angle, camera height, figure position, distant anchor, moon visibility, dynamic phenomenon, ground material, foreground frame, leading-line direction, costume color, and motion direction.

The distribution must include:

- about six images with people at 1–4% of frame height;
- about two at 5–8%;
- about one over-shoulder or oblique-rear image at 12–20%;
- three or four giant-moon images, not nine;
- one primary dynamic phenomenon per image, not a pile of unrelated effects;
- at least four independent scale cues and five readable depth layers in every image.

## Stage 2 — Generate and inspect clean stills

Call `imagegen` nine times, once per scene. A single request may return multiple files only when the tool guarantees nine separate outputs; never accept a rendered grid.

Use the invariant world bible plus the specific row of the matrix. Do not paste the entire long prompt blindly into every call. Keep invariant constraints stable and make the scene relation explicit.

After each result:

1. Locate the actual image file.
2. Inspect it at full frame.
3. Reject it if it fails the image gate in [references/qa-checklist.md](references/qa-checklist.md).
4. Save the accepted clean master as `stills/clean/S##_clean.png`.
5. Record the prompt and acceptance reason in the manifest.

Do not generate text, titles, subtitles, or watermark marks inside the world image.

## Stage 3 — Prepare watermarked still copies

The bundled mark is [assets/watermark/hx-celestial-order.png](assets/watermark/hx-celestial-order.png). It has already been cropped to its effective transparent bounds; do not substitute the original 2480×3508 mostly-empty canvas.

Run:

```bash
"$SKILL_DIR/scripts/apply-watermark.sh" \
  "$PROJECT_DIR/stills/clean/S01_clean.png" \
  "$PROJECT_DIR/stills/watermarked/S01.png"
```

Default placement:

- width: 14.6% of frame width;
- horizontal center: 38.2% of frame width, a lower-left golden-section anchor;
- bottom margin: 5% of frame height;
- opacity: 78%;
- two-pixel soft dark offset for contrast.

This is a starting geometry, not permission to cover a person, garment, moon edge, platform edge, or important reflection. Inspect each output and move the mark within the lower safe band when needed. Keep the logo away from right-side platform UI.

## Stage 4 — Animate clean stills in Flow/Veo

Read [references/veo-flow.md](references/veo-flow.md) before touching the browser.

For each accepted clean still:

1. Inspect the current Flow UI and record the exact visible model label and duration options.
2. Select `视频` → `素材` for image-driven generation.
3. Upload the clean still through Chrome. If the native file picker is inaccessible, load `computer-use:computer-use` and operate that picker; return to Chrome control afterward.
4. Enter a short shot-specific prompt. Keep one subject action, one environmental motion, and one restrained camera action.
5. Verify the generation button is enabled before clicking.
6. Generate, download, prove which file is new, inspect, and either accept or retry. Save accepted clips as `clips/accepted/S##_veo.mp4`.

If programmatic paste leaves the button gray, treat it as an input-event failure: focus the prompt, select all, delete, and use real keyboard-style text entry (`type_text`). Read the fresh UI state and verify the button becomes enabled. Do not keep clicking a gray button.

Use only model names and durations actually visible at run time. If the requested label (for example, “Veo 3.1 Lite”) has been renamed or is unavailable, report the visible alternatives before changing cost, model family, or production plan.

## Stage 5 — Assemble in HyperFrames

Read [references/hyperframes-assembly.md](references/hyperframes-assembly.md). Follow the mandatory HyperFrames composition contract and keep HTML as the source of truth.

The final composition must contain:

- nine accepted clips in designed order;
- restrained cuts or short dissolves aligned to musical phrases;
- one fixed watermark layer above the clips;
- the bundled music prepared with `scripts/prepare-music.sh`;
- selected Veo environmental SFX retained and ducked/mixed against the music;
- no narration, subtitles, or title cards unless the user asks for them.

Do not use elaborate camera motion in the edit to compensate for weak source clips. The sense of grandeur comes from scale, depth, wind, cloud/water motion, and patient timing.

## Stage 6 — Render and prove the result

Render a real MP4, then run:

```bash
"$SKILL_DIR/scripts/qa-final.sh" \
  "$PROJECT_DIR/final/celestial-palace.mp4" \
  "$EXPECTED_SECONDS" \
  "$PROJECT_DIR/clips/accepted"
```

Also create a one-frame-per-second contact sheet and inspect every scene boundary plus at least one mid-shot frame. Check watermark persistence, figure integrity, cloud/platform separation, duplicate clips, accidental blank frames, audio starts/ends, and any UI or subtitle overlays.

Only after those checks, report:

- absolute final MP4 path;
- duration, resolution, fps, and audio presence;
- the nine accepted still and clip directories;
- music trim and watermark placement;
- any known residual limitation.

## Included resources

- [references/world-bible.md](references/world-bible.md): invariant visual world.
- [references/nine-shot-matrix.md](references/nine-shot-matrix.md): diversity matrix and prompt templates.
- [references/veo-flow.md](references/veo-flow.md): Chrome/Flow operating procedure and failure recovery.
- [references/hyperframes-assembly.md](references/hyperframes-assembly.md): edit, audio, watermark, and render contract.
- [references/qa-checklist.md](references/qa-checklist.md): still, motion, and final gates.
- `assets/music/celestial-palace-theme.mp3`: bundled 65.44-second music source.
- `assets/watermark/hx-celestial-order.png`: cropped transparent watermark.
- `assets/asset-manifest.json`: provenance and checksums.
- `scripts/prepare-music.sh`: duration/offset trim with fades and loudness normalization; musical phrase selection remains a listening decision.
- `scripts/apply-watermark.sh`: deterministic still watermarking.
- `scripts/qa-assets.sh`: nine-file and aspect-ratio check.
- `scripts/qa-final.sh`: technical final MP4 check.
