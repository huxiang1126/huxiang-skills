#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 4 ]]; then
  echo "Usage: $0 <silent-video> <voiceover-audio> <output-video> <target-seconds>" >&2
  exit 2
fi

video_path=$1
audio_path=$2
output_path=$3
target_seconds=$4

if [[ ! -f "$video_path" || ! -f "$audio_path" ]]; then
  echo "Video or audio input is missing" >&2
  exit 1
fi
if ! awk -v value="$target_seconds" 'BEGIN { exit !(value > 0) }'; then
  echo "Target seconds must be a positive number" >&2
  exit 2
fi
if [[ -e "$output_path" ]]; then
  echo "Refusing to overwrite existing output; choose a new versioned path: $output_path" >&2
  exit 1
fi

mkdir -p "$(dirname "$output_path")"

ffmpeg -hide_banner -loglevel error -y \
  -i "$video_path" -i "$audio_path" \
  -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac \
  -af "areverse,silenceremove=start_periods=1:start_threshold=-45dB,areverse,apad" \
  -t "$target_seconds" -movflags +faststart "$output_path"

echo "$output_path"
