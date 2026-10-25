# QA Checklist

## Still gate — every image

- [ ] One independent file, not a grid/contact sheet.
- [ ] Vertical aspect close to 9:16; intended crop does not remove scale evidence.
- [ ] Five distinct depth layers.
- [ ] At least four separate, visible scale cues.
- [ ] Person size matches the nine-image distribution and is not decorative filler.
- [ ] Person is rear, oblique-rear, rear-side, or planned over-shoulder; anatomy and garment are intact.
- [ ] One dominant dynamic phenomenon or life sign, not multiple competing effects.
- [ ] Cloud top is below the figure's feet/platform edge.
- [ ] No railing or guardrail anywhere.
- [ ] No blank white band; open space contains atmosphere, light, or distant form.
- [ ] No dense city, era-specific palace copy, modern object, text, logo, or watermark.
- [ ] Moon appears only in designated shots and has physical lunar detail.
- [ ] Near forms are heavier/sharper; far forms softer/lighter.
- [ ] No warped perspective, fused fabric, duplicated figure, extra limb, or malformed structure.
- [ ] Adjacent accepted image changes at least four meaningful axes.

Run `"$SKILL_DIR/scripts/qa-assets.sh" "$PROJECT_DIR/stills/clean"` for exact names, file count, aspect, minimum size, and duplicate checks. Visual and near-duplicate checks remain mandatory.

## Motion gate — every clip

- [ ] Actual downloaded clip inspected, not just generation thumbnail.
- [ ] Original composition, architecture, costume, figure, and moon preserved.
- [ ] Only one restrained camera movement.
- [ ] Figure motion natural and slow; no slide, float, face turn, or morph.
- [ ] Hair, fabric, clouds/water/banner/pine share believable wind and gravity.
- [ ] No new building, railing, text, logo, or watermark.
- [ ] No camera orbit, whip, crash zoom, hidden cut, or sudden exposure jump.
- [ ] Environmental SFX only; no music or speech.
- [ ] Clip file recorded with model label, duration, prompt, attempt number, and rejection/acceptance note.

## Final MP4 gate

- [ ] Real file exists and opens.
- [ ] 1080×1920, 30 fps, expected duration, video and audio streams present.
- [ ] Nine accepted shots present; order and pace serve scale and calm.
- [ ] Music ends on a usable phrase with clean fades; no unintended loop or stretch.
- [ ] SFX are audible but do not fight the music; no clicks or abrupt ambience changes.
- [ ] Watermark is fixed, sharp, subordinate, and never covers a figure or key architecture.
- [ ] No black/blank frames, frozen failures, missing media, browser UI, subtitles, or title unless requested.
- [ ] One-frame-per-second contact sheet inspected.
- [ ] Every scene boundary and at least one mid-shot frame inspected.
- [ ] Absolute output path, technical properties, and any limitation reported.

Run `qa-final.sh` with the expected duration and accepted-clips directory. Its automatic gate covers dimensions, fps, duration, audio, black intervals, exact accepted names, decoding, and exact duplicates; it also exports 1fps samples and per-clip boundary frames. A human/agent must still inspect those frames to verify that all nine source scenes appear in the composite and that the watermark and subjects do not collide.
