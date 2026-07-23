#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 || $# -gt 4 ]]; then
  echo "Usage: $0 <final-video> <approved-still> <output-dir> [expected-seconds]" >&2
  exit 2
fi

video_path=$1
approved_still=$2
output_dir=$3
expected_seconds=${4:-5}

if ! awk -v value="$expected_seconds" 'BEGIN { exit !(value > 0 && value <= 60) }'; then
  echo "Expected seconds must be greater than 0 and at most 60" >&2
  exit 2
fi

if [[ ! -f "$video_path" ]]; then
  echo "Video not found: $video_path" >&2
  exit 1
fi

if [[ ! -f "$approved_still" ]]; then
  echo "Approved still not found: $approved_still" >&2
  exit 1
fi
if [[ -e "$output_dir/qa-summary.md" || -e "$output_dir/metadata.json" ]]; then
  echo "Refusing to overwrite existing QA; choose a new versioned output directory: $output_dir" >&2
  exit 1
fi

mkdir -p "$output_dir"

ffprobe -v error -show_streams -show_format -of json "$video_path" > "$output_dir/metadata.json"

ffmpeg -hide_banner -loglevel error -y \
  -i "$video_path" -vf "select=eq(n\,0)" -frames:v 1 \
  "$output_dir/first-frame.jpg"

ffmpeg -hide_banner -loglevel error -y \
  -sseof -0.05 -i "$video_path" -frames:v 1 \
  "$output_dir/video-last-frame.jpg"

tile_count=$(awk -v value="$expected_seconds" 'BEGIN { count=int(value + 0.999); if (count < 2) count=2; if (count > 12) count=12; print count }')
sample_fps=$(awk -v value="$expected_seconds" -v count="$tile_count" 'BEGIN { printf "%.8f", count / value }')

ffmpeg -hide_banner -loglevel error -y \
  -i "$video_path" -vf "fps=${sample_fps},scale=180:320,tile=${tile_count}x1" -frames:v 1 \
  "$output_dir/contact-sheet.jpg"

ffmpeg -hide_banner -loglevel error -y \
  -i "$approved_still" -i "$output_dir/video-last-frame.jpg" \
  -filter_complex "[0:v]scale=360:640:force_original_aspect_ratio=increase,crop=360:640[a];[1:v]scale=360:640:force_original_aspect_ratio=increase,crop=360:640[b];[a][b]hstack=inputs=2" \
  -frames:v 1 "$output_dir/end-frame-comparison.jpg"

width=$(jq -r '[.streams[] | select(.codec_type == "video")][0].width // 0' "$output_dir/metadata.json")
height=$(jq -r '[.streams[] | select(.codec_type == "video")][0].height // 0' "$output_dir/metadata.json")
duration=$(jq -r '.format.duration // "0"' "$output_dir/metadata.json")
audio_streams=$(jq '[.streams[] | select(.codec_type == "audio")] | length' "$output_dir/metadata.json")

technical_verdict=PASS
if [[ "$width" != "720" || "$height" != "1280" || "$audio_streams" != "0" ]]; then
  technical_verdict=FAIL
fi
if ! awk -v value="$duration" -v expected="$expected_seconds" 'BEGIN { tolerance=0.08; exit !(value >= expected-tolerance && value <= expected+tolerance) }'; then
  technical_verdict=FAIL
fi

cat > "$output_dir/qa-summary.md" <<EOF
# Technical QA

- Verdict: ${technical_verdict}
- Dimensions: ${width}x${height}
- Duration: ${duration} seconds
- Expected duration: ${expected_seconds} seconds
- Audio streams: ${audio_streams}
- Contact sheet: contact-sheet.jpg
- First frame: first-frame.jpg
- End-frame comparison: end-frame-comparison.jpg

Technical PASS does not prove visual PASS. Open the contact sheet and end-frame comparison and judge assembly progression, fake lettering, camera stability and final-frame fidelity.
EOF

echo "$output_dir/qa-summary.md"
