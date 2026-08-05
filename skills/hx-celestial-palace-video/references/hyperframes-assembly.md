# HyperFrames Assembly Contract

Load the mandatory HyperFrames skills before implementing. Use HyperFrames' HTML composition as source of truth and render a real 1080×1920, 30 fps MP4.

## Sequence and pace

- Require all nine accepted clips `S01`–`S09`. A missing clip is a blocker; reduce the shot count only after explicit user approval.
- Begin with a decisive scale reveal, vary direction and figure distance, and reserve one 8-second hero hold for the emotional peak.
- Prefer hard cuts on musical accents or 6–12-frame dissolves. Avoid transition packs, spins, zoom tunnels, and decorative motion graphics.
- Do not crop away the scale proof: giant off-frame structure, tiny figure, low cloud plane, and distant anchor need room.
- No subtitles, narration, title, or decorative copy by default. This is a music-led visual film unless the user requests text.

## Music

Bundled source: `assets/music/celestial-palace-theme.mp3` (about 65.44 seconds).

Create a project copy:

```bash
"$SKILL_DIR/scripts/prepare-music.sh" \
  FINAL_SECONDS \
  "$PROJECT_DIR/audio/celestial-theme.m4a"
```

- Choose the final cut length around a musical phrase or cadence rather than cutting on an arbitrary frame.
- The helper accepts an optional source and start offset, normalizes conservatively, and adds short fade-in/fade-out. Listen first, choose an actual musical phrase/cadence, then pass the duration and offset; the script does not detect phrases automatically.
- Never loop by default. If the film exceeds the source, shorten the edit or ask before looping/replacing music.
- Avoid time-stretch; if absolutely necessary, keep it within ±3% and inspect artifacts.
- Keep the original bundled file unchanged.
- Record that the user supplied and authorized the asset for this workflow. Public release still requires the user to hold the necessary music rights and accept possible Content ID claims.

## SFX mix

- Keep useful Veo wind, distant waterfall, cloth, footstep, and crane sounds.
- Remove any generated music or speech from individual clips.
- Let environmental SFX remain audible under the music, typically 4–8 dB below foreground music depending on density.
- Use short crossfades between clip audio beds to prevent clicks and abrupt ambience changes.
- No hard limiter pumping. Target a clean web master with true peak at or below about −1.5 dBTP.

## Watermark layer

Use `assets/watermark/hx-celestial-order.png`, not the original mostly-empty canvas.

Default fixed geometry on 1080×1920:

- rendered width about 158 px (14.6%);
- center x about 413 px (38.2% of width);
- bottom margin about 96 px (5% of height);
- opacity 0.78;
- subtle two-pixel dark shadow/offset.

The mark must stay sharp and constant while the underlying video moves. If it covers a figure or dominant line in any shot, animate a restrained horizontal relocation inside the lower safe band during the transition, or use a scene-specific alternate position. Never scale-pulse or fly the mark in.

## Render checks

Render the MP4, not only the browser preview. Verify:

- 1080×1920, 30 fps, intended duration;
- nine shots present and in order;
- audio stream present; clean head and tail;
- no blank/black first frame, duplicated shot, frozen failed clip, or missing media;
- no accidental subtitles, browser UI, generated watermark, or title;
- fixed watermark visible but subordinate;
- at least one inspected mid-frame for every shot and every boundary frame;
- people, garments, columns, platforms, moon, clouds, and distant structures remain readable after edit crops.

Keep the HyperFrames project and final MP4 path in `production-manifest.md`.
