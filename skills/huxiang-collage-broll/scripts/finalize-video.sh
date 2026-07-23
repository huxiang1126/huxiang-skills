#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 || $# -gt 4 ]]; then
  echo "Usage: $0 <raw-video> <output-video> <direct|reverse> [target-seconds]" >&2
  exit 2
fi

input_video=$1
output_video=$2
route=$3
target_seconds=${4:-5}

if [[ ! -f "$input_video" ]]; then
  echo "Input video not found: $input_video" >&2
  exit 1
fi

if [[ "$route" != "direct" && "$route" != "reverse" ]]; then
  echo "Route must be direct or reverse" >&2
  exit 2
fi

if ! awk -v value="$target_seconds" 'BEGIN { exit !(value > 0 && value <= 60) }'; then
  echo "Target seconds must be greater than 0 and at most 60" >&2
  exit 2
fi
if [[ -e "$output_video" ]]; then
  echo "Refusing to overwrite existing output; choose a new versioned path: $output_video" >&2
  exit 1
fi

duration=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$input_video")
if ! awk -v value="$duration" 'BEGIN { exit !(value > 0) }'; then
  echo "Could not determine a positive input duration" >&2
  exit 1
fi

mkdir -p "$(dirname "$output_video")"

speed_factor=$(awk -v input="$duration" -v target="$target_seconds" 'BEGIN { printf "%.10f", target / input }')
base_filter="scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,fps=30"

if [[ "$route" == "reverse" ]]; then
  video_filter="reverse,${base_filter},setpts=${speed_factor}*PTS"
else
  video_filter="${base_filter},setpts=${speed_factor}*PTS"
fi

ffmpeg -hide_banner -loglevel error -y \
  -i "$input_video" \
  -map 0:v:0 -vf "$video_filter" -an -t "$target_seconds" \
  -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p -movflags +faststart \
  "$output_video"

echo "$output_video"
