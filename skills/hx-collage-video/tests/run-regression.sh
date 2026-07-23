#!/usr/bin/env bash
set -euo pipefail

skill_dir=$(cd "$(dirname "$0")/.." && pwd)
fixtures_dir="$skill_dir/tests/fixtures"
test_dir=$(mktemp -d /tmp/hx-collage-video-regression.XXXXXX)
trap 'rm -rf "$test_dir"' EXIT

expect_fail() {
  if "$@" >/dev/null 2>&1; then
    echo "Expected failure but command passed: $*" >&2
    exit 1
  fi
}

node "$skill_dir/scripts/lint-ledgers.mjs" \
  --storyboard "$fixtures_dir/storyboard.json" \
  --beats "$fixtures_dir/beats-valid.json" \
  --claims "$fixtures_dir/claims-valid.json" \
  --captions "$fixtures_dir/caption-beats-valid.json" \
  --safe-zones "$fixtures_dir/caption-safe-zones-valid.json" \
  > "$test_dir/lint-valid.json"

jq '.beats=[]' "$fixtures_dir/beats-valid.json" > "$test_dir/beats-empty.json"
expect_fail node "$skill_dir/scripts/lint-ledgers.mjs" \
  --storyboard "$fixtures_dir/storyboard.json" \
  --beats "$test_dir/beats-empty.json"

jq '.layers[0].beat_ids=["UNKNOWN"]' "$fixtures_dir/asset-collage-valid.json" > "$test_dir/asset-collage-invalid.json"
jq '.scenes[0].asset_collage="'"$test_dir"'/asset-collage-invalid.json"' "$fixtures_dir/storyboard.json" > "$test_dir/storyboard-invalid-collage.json"
expect_fail node "$skill_dir/scripts/lint-ledgers.mjs" \
  --storyboard "$test_dir/storyboard-invalid-collage.json" \
  --beats "$fixtures_dir/beats-valid.json"

jq 'del(.tracks[0].phases[] | select(.phase=="enter"))' "$fixtures_dir/motion-plan-valid.json" > "$test_dir/motion-plan-no-enter.json"
jq \
  --arg asset "$fixtures_dir/asset-collage-valid.json" \
  --arg motion "$test_dir/motion-plan-no-enter.json" \
  '.scenes[0].asset_collage=$asset | .scenes[0].motion_plan=$motion' \
  "$fixtures_dir/storyboard.json" > "$test_dir/storyboard-invalid-motion.json"
expect_fail node "$skill_dir/scripts/lint-ledgers.mjs" \
  --storyboard "$test_dir/storyboard-invalid-motion.json" \
  --beats "$fixtures_dir/beats-valid.json"

jq \
  '.tracks[0].phases[1].intensity=4
   | .events[0].intensity=4
   | .events[0].start=1.8
   | .events[0].end=2.2' \
  "$fixtures_dir/motion-plan-valid.json" > "$test_dir/motion-plan-over-budget.json"
jq \
  --arg asset "$fixtures_dir/asset-collage-valid.json" \
  --arg motion "$test_dir/motion-plan-over-budget.json" \
  '.scenes[0].asset_collage=$asset | .scenes[0].motion_plan=$motion' \
  "$fixtures_dir/storyboard.json" > "$test_dir/storyboard-over-budget.json"
expect_fail node "$skill_dir/scripts/lint-ledgers.mjs" \
  --storyboard "$test_dir/storyboard-over-budget.json" \
  --beats "$fixtures_dir/beats-valid.json"

jq \
  '.events[0].audio_source="bgm"
   | .events[0].sound_policy="music_sync"' \
  "$fixtures_dir/motion-plan-valid.json" > "$test_dir/motion-plan-bgm.json"
jq \
  --arg asset "$fixtures_dir/asset-collage-valid.json" \
  --arg motion "$test_dir/motion-plan-bgm.json" \
  '.scenes[0].asset_collage=$asset | .scenes[0].motion_plan=$motion' \
  "$fixtures_dir/storyboard.json" > "$test_dir/storyboard-bgm.json"
expect_fail node "$skill_dir/scripts/lint-ledgers.mjs" \
  --storyboard "$test_dir/storyboard-bgm.json" \
  --beats "$fixtures_dir/beats-valid.json"

ffmpeg -hide_banner -loglevel error -f lavfi -i "sine=frequency=440:sample_rate=48000:duration=3" -ar 48000 -ac 2 "$test_dir/narration.wav"
ffmpeg -hide_banner -loglevel error -f lavfi -i "sine=frequency=880:sample_rate=48000:duration=3" -af "volume=0.08" -ar 48000 -ac 2 "$test_dir/sfx.wav"
ffmpeg -hide_banner -loglevel error -i "$test_dir/narration.wav" -i "$test_dir/sfx.wav" \
  -filter_complex "[0:a][1:a]amix=inputs=2:duration=longest:normalize=0[a]" -map "[a]" -ar 48000 -ac 2 "$test_dir/no-music-reference.wav"
ffmpeg -hide_banner -loglevel error \
  -f lavfi -i "color=c=0xE8E1C5:s=720x1280:r=30:d=3" \
  -i "$test_dir/no-music-reference.wav" -t 3 -shortest \
  -c:v libx264 -preset ultrafast -pix_fmt yuv420p -c:a aac -b:a 192k \
  "$test_dir/master.mp4"

bash "$skill_dir/scripts/qa-story.sh" \
  "$test_dir/master.mp4" "$fixtures_dir/captions.srt" \
  "$test_dir/narration.wav" "$test_dir/sfx.wav" \
  "$fixtures_dir/beats-valid.json" "$fixtures_dir/caption-beats-valid.json" \
  "$test_dir/story-qa-valid" 3

jq '.beats[0].master_window.end=1.0' "$fixtures_dir/beats-valid.json" > "$test_dir/beats-too-short.json"
expect_fail bash "$skill_dir/scripts/qa-story.sh" \
  "$test_dir/master.mp4" "$fixtures_dir/captions.srt" \
  "$test_dir/narration.wav" "$test_dir/sfx.wav" \
  "$test_dir/beats-too-short.json" "$fixtures_dir/caption-beats-valid.json" \
  "$test_dir/story-qa-short-beat" 3

expect_fail bash "$skill_dir/scripts/qa-story.sh" \
  "$test_dir/master.mp4" "$fixtures_dir/captions.srt" \
  "$test_dir/narration.wav" "$test_dir/sfx.wav" \
  "$fixtures_dir/beats-valid.json" "$fixtures_dir/caption-beats-valid.json" \
  "$test_dir/story-qa-truncated" 6

printf '%s\n' "not audio" > "$test_dir/not-audio.wav"
expect_fail bash "$skill_dir/scripts/qa-story.sh" \
  "$test_dir/master.mp4" "$fixtures_dir/captions.srt" \
  "$test_dir/not-audio.wav" "$test_dir/sfx.wav" \
  "$fixtures_dir/beats-valid.json" "$fixtures_dir/caption-beats-valid.json" \
  "$test_dir/story-qa-fake-stem" 3

narration_hash=$(shasum -a 256 "$test_dir/narration.wav" | awk '{print $1}')
sfx_hash=$(shasum -a 256 "$test_dir/sfx.wav" | awk '{print $1}')
reference_hash=$(shasum -a 256 "$test_dir/no-music-reference.wav" | awk '{print $1}')
jq -n \
  --arg narrationPath "$test_dir/narration.wav" \
  --arg narrationHash "$narration_hash" \
  --arg sfxPath "$test_dir/sfx.wav" \
  --arg sfxHash "$sfx_hash" \
  --arg referencePath "$test_dir/no-music-reference.wav" \
  --arg referenceHash "$reference_hash" \
  '{
    version:"2.3.0",
    background_music_authorized:false,
    tracks:[
      {id:"narration",kind:"narration",path:$narrationPath,sha256:$narrationHash,provider:"fixture",voice_id:"fixture-tone",voice_authorization:"local_synthetic"},
      {id:"sfx",kind:"sfx",path:$sfxPath,sha256:$sfxHash}
    ],
    mixes:{no_music:["narration","sfx"]},
    reference_mixes:{no_music:{path:$referencePath,sha256:$referenceHash}}
  }' > "$test_dir/audio-manifest.json"

node "$skill_dir/scripts/lint-ledgers.mjs" \
  --storyboard "$fixtures_dir/storyboard.json" \
  --beats "$fixtures_dir/beats-valid.json" \
  --claims "$fixtures_dir/claims-valid.json" \
  --captions "$fixtures_dir/caption-beats-valid.json" \
  --safe-zones "$fixtures_dir/caption-safe-zones-valid.json" \
  --audio-manifest "$test_dir/audio-manifest.json" \
  > "$test_dir/lint-with-audio-valid.json"

jq 'del(.tracks[] | select(.kind=="narration") | .voice_authorization)' "$test_dir/audio-manifest.json" > "$test_dir/audio-manifest-no-authorization.json"
expect_fail node "$skill_dir/scripts/lint-ledgers.mjs" \
  --storyboard "$fixtures_dir/storyboard.json" \
  --beats "$fixtures_dir/beats-valid.json" \
  --audio-manifest "$test_dir/audio-manifest-no-authorization.json"

bash "$skill_dir/scripts/qa-audio.sh" \
  "$test_dir/master.mp4" "$test_dir/audio-manifest.json" "$test_dir/audio-qa-valid"

ffmpeg -hide_banner -loglevel error \
  -f lavfi -i "color=c=0xE8E1C5:s=720x1280:r=30:d=3" \
  -f lavfi -i "sine=frequency=220:sample_rate=48000:duration=3" -t 3 -shortest \
  -c:v libx264 -preset ultrafast -pix_fmt yuv420p -c:a aac -b:a 192k -ar 48000 -ac 2 \
  "$test_dir/wrong-audio-master.mp4"
expect_fail bash "$skill_dir/scripts/qa-audio.sh" \
  "$test_dir/wrong-audio-master.mp4" "$test_dir/audio-manifest.json" "$test_dir/audio-qa-wrong-track"

expect_fail bash "$skill_dir/scripts/mux-voiceover.sh" \
  "$test_dir/master.mp4" "$test_dir/narration.wav" "$test_dir/mux-without-duration.mp4"

echo "PASS: hx-collage-video v2.3 regression suite"
