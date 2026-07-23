# Final visual coverage audit

This audit prevents a common failure: roles and actions exist in prompts, keyframes, or source clips but disappear after generation, retiming, cropping, captioning, or assembly.

## Four states

Never collapse these states:

1. `planned` — written in treatment or storyboard.
2. `asset_generated` — a still or video asset exists locally.
3. `visible_in_scene` — the action is readable in the standardized scene clip.
4. `visible_in_master` — the action survives in the final rendered MP4.

Only state 4 may appear as a positive delivery claim.

## Ledger

Create the single lifecycle ledger at `ledgers/beats.json` during storyboard design. Do not maintain separate storyboard beats, generation beats and final-coverage IDs. Final QA snapshots this ledger into its versioned output directory; the editable source remains one file.

```json
{
  "version": "2.3.0",
  "coverage_required": true,
  "beats": [
    {
      "beat_id": "S06-B03",
      "scene_id": "S06",
      "required": true,
      "role": "dock porter",
      "action": "carries a porcelain crate from ship to merchant",
      "story_function": "shows who physically moves trade",
      "min_visible_seconds": 1.5,
      "state": "visible_in_master",
      "assembly_route": "timeline_collage",
      "master_window": {"start": 38.1, "end": 39.9},
      "notes": "foreground action, clear despite captions"
    }
  ]
}
```

Allowed states are `planned`, `asset_generated`, `visible_in_scene`, `visible_in_master`, `missing`, `unclear`, or `intentionally_removed`. `intentionally_removed` requires `required:false`, a reason and removal of the corresponding user-facing promise.

## What counts as visible

- The role is identifiable without relying only on narration or captions.
- The action is visible, not merely implied by a prop.
- Primary action defaults to at least 1.5 continuous seconds; secondary context defaults to at least 1.0 second.
- The subject is not hidden behind subtitles, cropped to an unusable fragment, reduced to crowd texture, or present only in a transition blur.
- A valid `master_window` exists inside the real MP4 and is at least `min_visible_seconds` long.
- Final QA automatically extracts entry/mid/exit frames and a 4 fps strip from that window.

## Audit procedure

1. Generate a final-master contact sheet at 1 fps for navigation.
2. Review the actual MP4 at every promised beat time; contact sheets are navigation aids, not sufficient proof by themselves.
3. Run final QA to create per-beat entry/mid/exit frames and a 4 fps evidence strip from the final master.
4. Update `master_window`, state and notes only after watching those pixels.
5. If any required beat is `missing`, `unclear`, too short or outside the master duration, verdict is FAIL. Repair the edit or deliberately remove the promise.
6. Derive the delivery summary from the ledger. Never copy the storyboard cast list into the final response.

Timeline duration and extracted frames can automatically reject a false claim, but they cannot automatically promote a beat. A human must still decide whether the role and action are identifiable.

## Recommended command

```bash
bash scripts/qa-story.sh \
  final/story-master.mp4 final/captions.srt final/narration.wav final/sfx-mix.wav \
  ledgers/beats.json ledgers/caption-beats.json final/qa-vNN <expected-seconds>
```

The script validates actual media, duration, frame rate, required beat windows and caption records; creates a 1 fps navigation sheet; and extracts 4 fps per-beat evidence. Black/freeze detections are warnings because deliberate holds and paper-field transitions can trigger them. Human visual judgment is still required for character actions and caption design.
