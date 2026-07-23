#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 8 ]]; then
  echo "Usage: $0 <story-master.mp4> <captions.srt> <narration.wav> <sfx-mix.wav> <beats.json> <caption-beats.json> <output-dir> <expected-seconds>" >&2
  exit 2
fi

video_path=$1
captions_path=$2
narration_path=$3
sfx_path=$4
beats_path=$5
caption_beats_path=$6
output_dir=$7
expected_seconds=$8

if ! awk -v value="$expected_seconds" 'BEGIN { exit !(value > 0) }'; then
  echo "Expected seconds must be a positive number" >&2
  exit 2
fi

for required_file in "$video_path" "$captions_path" "$narration_path" "$sfx_path" "$beats_path" "$caption_beats_path"; do
  if [[ ! -s "$required_file" ]]; then
    echo "Required non-empty file not found: $required_file" >&2
    exit 1
  fi
done
if [[ -e "$output_dir/qa-report.json" || -e "$output_dir/qa-report.md" ]]; then
  echo "Refusing to overwrite existing QA; choose a new versioned output directory: $output_dir" >&2
  exit 1
fi

for media_file in "$video_path" "$narration_path" "$sfx_path"; do
  if ! ffprobe -v error -show_format -show_streams -of json "$media_file" >/dev/null; then
    echo "Media file is not decodable: $media_file" >&2
    exit 1
  fi
done
for audio_stem in "$narration_path" "$sfx_path"; do
  if ! ffprobe -v error -select_streams a:0 -show_entries stream=codec_type -of csv=p=0 "$audio_stem" | grep -qx audio; then
    echo "Stem is not a decodable audio file: $audio_stem" >&2
    exit 1
  fi
done

if ! awk 'BEGIN { blocks=0; timecodes=0 } /^[0-9]+[[:space:]]*$/ { blocks++ } /-->/ { timecodes++ } END { exit !(blocks > 0 && timecodes > 0) }' "$captions_path"; then
  echo "Captions file does not look like a non-empty SRT: $captions_path" >&2
  exit 1
fi

if ! jq -e '.version == "2.3.0" and (.coverage_required | type == "boolean") and (.beats | type == "array")' "$beats_path" >/dev/null; then
  echo "Beat ledger must match version 2.3.0 base contract: $beats_path" >&2
  exit 1
fi
if ! jq -e '.version == "2.3.0" and (.mode == "default" or .mode == "caption_led") and (.beats | type == "array") and (.beats | length > 0)' "$caption_beats_path" >/dev/null; then
  echo "Caption ledger must match version 2.3.0 base contract: $caption_beats_path" >&2
  exit 1
fi

mkdir -p "$output_dir"
ffprobe -v error -show_streams -show_format -of json "$video_path" > "$output_dir/metadata.json"

width=$(jq -r '[.streams[] | select(.codec_type == "video")][0].width // 0' "$output_dir/metadata.json")
height=$(jq -r '[.streams[] | select(.codec_type == "video")][0].height // 0' "$output_dir/metadata.json")
fps_ratio=$(jq -r '[.streams[] | select(.codec_type == "video")][0].r_frame_rate // "0/1"' "$output_dir/metadata.json")
duration=$(jq -r '.format.duration // "0"' "$output_dir/metadata.json")
audio_streams=$(jq '[.streams[] | select(.codec_type == "audio")] | length' "$output_dir/metadata.json")
video_streams=$(jq '[.streams[] | select(.codec_type == "video")] | length' "$output_dir/metadata.json")
fps=$(awk -F/ -v ratio="$fps_ratio" 'BEGIN { split(ratio, parts, "/"); if (parts[2] == 0) print 0; else printf "%.6f", parts[1] / parts[2] }')

if ! awk -v value="$duration" 'BEGIN { exit !(value > 0) }'; then
  echo "Could not determine a positive video duration" >&2
  exit 1
fi

technical_verdict=PASS
if [[ "$video_streams" != "1" || "$audio_streams" -lt 1 || "$width" -lt 720 || "$height" -lt 1280 || $(( width * 16 )) -ne $(( height * 9 )) ]]; then
  technical_verdict=FAIL
fi
if ! awk -v value="$duration" -v expected="$expected_seconds" 'BEGIN { tolerance=0.35; exit !(value >= expected-tolerance && value <= expected+tolerance) }'; then
  technical_verdict=FAIL
fi
if ! awk -v value="$fps" 'BEGIN { exit !(value >= 29.9 && value <= 30.1) }'; then
  technical_verdict=FAIL
fi

sample_count=$(awk -v value="$duration" 'BEGIN { print int(value + 0.999999) }')
tile_columns=8
tile_rows=$(( (sample_count + tile_columns - 1) / tile_columns ))
ffmpeg -hide_banner -loglevel error -y \
  -i "$video_path" -vf "fps=1,scale=135:240,tile=${tile_columns}x${tile_rows}:padding=2:margin=2:color=#111111" -frames:v 1 \
  "$output_dir/contact-sheet-1fps.jpg"

ffmpeg -hide_banner -nostats -i "$video_path" \
  -vf "blackdetect=d=0.05:pix_th=0.10,freezedetect=n=-55dB:d=0.5" -an -f null - \
  >"$output_dir/frame-anomaly-scan.log" 2>&1 || true
black_segments=$(rg -c 'black_start:' "$output_dir/frame-anomaly-scan.log" 2>/dev/null || true)
freeze_segments=$(rg -c 'freeze_start:' "$output_dir/frame-anomaly-scan.log" 2>/dev/null || true)
black_segments=${black_segments:-0}
freeze_segments=${freeze_segments:-0}

coverage_required=$(jq -r '.coverage_required' "$beats_path")
promised_beats=$(jq '[.beats[] | select(.required == true)] | length' "$beats_path")
coverage_errors=0
coverage_frames_dir="$output_dir/coverage-evidence"
mkdir -p "$coverage_frames_dir"

while IFS=$'\t' read -r beat_id state required min_seconds start end; do
  if [[ ! "$beat_id" =~ ^[A-Za-z0-9._-]+$ ]]; then
    echo "Unsafe beat id: $beat_id" >&2
    coverage_errors=$((coverage_errors + 1))
    continue
  fi
  if [[ "$required" != "true" ]]; then
    continue
  fi
  if [[ "$state" != "visible_in_master" ]]; then
    echo "Required beat is not visible_in_master: $beat_id ($state)" >&2
    coverage_errors=$((coverage_errors + 1))
    continue
  fi
  if [[ "$start" == "null" || "$end" == "null" ]]; then
    echo "Required visible beat has no master_window: $beat_id" >&2
    coverage_errors=$((coverage_errors + 1))
    continue
  fi
  if ! awk -v start="$start" -v end="$end" -v duration="$duration" -v minimum="$min_seconds" 'BEGIN { exit !(start >= 0 && end <= duration && end > start && end-start+0.000001 >= minimum) }'; then
    echo "Invalid or too-short master_window for $beat_id: ${start}-${end}s" >&2
    coverage_errors=$((coverage_errors + 1))
    continue
  fi
  midpoint=$(awk -v start="$start" -v end="$end" 'BEGIN { printf "%.3f", start + ((end-start)/2) }')
  exitpoint=$(awk -v start="$start" -v end="$end" 'BEGIN { printf "%.3f", end - ((end-start)*0.05) }')
  ffmpeg -hide_banner -loglevel error -y -ss "$start" -i "$video_path" -frames:v 1 "$coverage_frames_dir/${beat_id}-entry.jpg"
  ffmpeg -hide_banner -loglevel error -y -ss "$midpoint" -i "$video_path" -frames:v 1 "$coverage_frames_dir/${beat_id}-mid.jpg"
  ffmpeg -hide_banner -loglevel error -y -ss "$exitpoint" -i "$video_path" -frames:v 1 "$coverage_frames_dir/${beat_id}-exit.jpg"
  beat_duration=$(awk -v start="$start" -v end="$end" 'BEGIN { printf "%.3f", end-start }')
  tile_count=$(awk -v value="$beat_duration" 'BEGIN { count=int(value*4+0.999); if (count < 3) count=3; if (count > 40) count=40; print count }')
  ffmpeg -hide_banner -loglevel error -y -ss "$start" -t "$beat_duration" -i "$video_path" \
    -vf "fps=4,scale=135:240,tile=${tile_count}x1:padding=2:margin=2:color=#111111" -frames:v 1 \
    "$coverage_frames_dir/${beat_id}-strip-4fps.jpg"
done < <(jq -r '.beats[] | [.beat_id, .state, .required, .min_visible_seconds, (.master_window.start // "null"), (.master_window.end // "null")] | @tsv' "$beats_path")

if [[ "$coverage_required" == "true" && "$promised_beats" -eq 0 ]]; then
  echo "coverage_required=true but the ledger has zero required beats" >&2
  coverage_errors=$((coverage_errors + 1))
fi
coverage_verdict=PASS
if [[ "$coverage_errors" -ne 0 ]]; then coverage_verdict=FAIL; fi

caption_errors=0
caption_frames_dir="$output_dir/caption-evidence"
mkdir -p "$caption_frames_dir"
hero_caption_beats=0
while IFS=$'\t' read -r beat_id mode beat_start beat_end text semantic_motion visual_avoid_type; do
  if [[ ! "$beat_id" =~ ^[A-Za-z0-9._-]+$ ]]; then
    echo "Unsafe caption beat id: $beat_id" >&2
    caption_errors=$((caption_errors + 1))
    continue
  fi
  if ! awk -v start="$beat_start" -v end="$beat_end" -v duration="$duration" 'BEGIN { exit !(start >= 0 && end <= duration && end > start) }'; then
    echo "Invalid caption timing for $beat_id" >&2
    caption_errors=$((caption_errors + 1))
    continue
  fi
  if [[ -z "$text" || -z "$semantic_motion" || "$visual_avoid_type" != "array" ]]; then
    echo "Incomplete caption record: $beat_id" >&2
    caption_errors=$((caption_errors + 1))
    continue
  fi
  if [[ "$mode" == "thesis" || "$mode" == "date_event" ]]; then
    hero_caption_beats=$((hero_caption_beats + 1))
    midpoint=$(awk -v start="$beat_start" -v end="$beat_end" 'BEGIN { printf "%.3f", start + ((end-start)/2) }')
    exitpoint=$(awk -v start="$beat_start" -v end="$beat_end" 'BEGIN { printf "%.3f", end - ((end-start)*0.05) }')
    ffmpeg -hide_banner -loglevel error -y -ss "$beat_start" -i "$video_path" -frames:v 1 "$caption_frames_dir/${beat_id}-entry.jpg"
    ffmpeg -hide_banner -loglevel error -y -ss "$midpoint" -i "$video_path" -frames:v 1 "$caption_frames_dir/${beat_id}-mid.jpg"
    ffmpeg -hide_banner -loglevel error -y -ss "$exitpoint" -i "$video_path" -frames:v 1 "$caption_frames_dir/${beat_id}-exit.jpg"
  fi
done < <(jq -r '.beats[] | [.id, .mode, .start, .end, .zh, .semantic_motion, (.visual_avoid | type)] | @tsv' "$caption_beats_path")

caption_mode=$(jq -r '.mode' "$caption_beats_path")
if [[ "$caption_mode" == "caption_led" && "$hero_caption_beats" -eq 0 ]]; then
  echo "caption_led mode has zero hero captions" >&2
  caption_errors=$((caption_errors + 1))
fi
caption_verdict=PASS
if [[ "$caption_errors" -ne 0 ]]; then caption_verdict=FAIL; fi

cat > "$output_dir/qa-report.md" <<EOF
# Story video QA v2.3

- Technical verdict: ${technical_verdict}
- Dimensions: ${width}x${height}
- FPS: ${fps}
- Duration: ${duration} seconds
- Expected duration: ${expected_seconds} seconds
- Video streams: ${video_streams}
- Audio streams: ${audio_streams}
- Captions stem: decodable structure checked
- Narration stem: decodable audio checked
- SFX stem: decodable audio checked
- Dense final-master contact sheet: contact-sheet-1fps.jpg
- Frame anomaly scan: frame-anomaly-scan.log
- Black-segment warnings: ${black_segments}
- Freeze-segment warnings: ${freeze_segments}
- Visual coverage verdict: ${coverage_verdict}
- Coverage required: ${coverage_required}
- Required visual beats: ${promised_beats}
- Coverage forensic errors: ${coverage_errors}
- Per-beat evidence: coverage-evidence/*-{entry,mid,exit,strip-4fps}.jpg
- Caption ledger verdict: ${caption_verdict}
- Caption mode: ${caption_mode}
- Hero caption beats: ${hero_caption_beats}
- Caption record errors: ${caption_errors}
- Final-master caption evidence: caption-evidence/*-{entry,mid,exit}.jpg

Technical PASS does not prove story, caption design, continuity, sound, or visual coverage PASS. Black/freeze detections are review warnings because intentional holds and paper-field transitions can trigger them. The script proves timing, files, and evidence extraction; a human must still verify that each promised action is actually readable and each caption is attractive, synchronized, and clear.
EOF

overall_verdict=PASS
if [[ "$technical_verdict" != "PASS" || "$coverage_verdict" != "PASS" || "$caption_verdict" != "PASS" ]]; then
  overall_verdict=FAIL
fi

jq -n \
  --arg version "2.3.0" \
  --arg verdict "$overall_verdict" \
  --arg technical "$technical_verdict" \
  --arg coverage "$coverage_verdict" \
  --arg captions "$caption_verdict" \
  --argjson blackWarnings "$black_segments" \
  --argjson freezeWarnings "$freeze_segments" \
  '{version:$version, verdict:$verdict, technical:$technical, visualCoverage:$coverage, captions:$captions, warnings:{blackSegments:$blackWarnings, freezeSegments:$freezeWarnings}}' \
  > "$output_dir/qa-report.json"

echo "$output_dir/qa-report.md"
if [[ "$overall_verdict" != "PASS" ]]; then exit 1; fi
