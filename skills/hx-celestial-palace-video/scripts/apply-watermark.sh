#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 || $# -gt 3 ]]; then
  echo "Usage: $0 INPUT_IMAGE OUTPUT_IMAGE [WATERMARK_PNG]" >&2
  exit 64
fi

input_path="$1"
output_path="$2"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="$(cd "$script_dir/.." && pwd)"
watermark_path="${3:-$skill_dir/assets/watermark/hx-celestial-order.png}"

command -v ffmpeg >/dev/null || { echo "ffmpeg is required" >&2; exit 69; }
command -v ffprobe >/dev/null || { echo "ffprobe is required" >&2; exit 69; }
[[ -f "$input_path" ]] || { echo "Missing input image: $input_path" >&2; exit 66; }
[[ -f "$watermark_path" ]] || { echo "Missing watermark: $watermark_path" >&2; exit 66; }

frame_width="$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 "$input_path")"
mark_width="$(awk -v w="$frame_width" 'BEGIN { printf "%d", w*0.146 }')"
mkdir -p "$(dirname "$output_path")"

ffmpeg -y -hide_banner -loglevel error -i "$input_path" -i "$watermark_path" \
  -filter_complex "[1:v]scale=${mark_width}:-1,format=rgba,colorchannelmixer=aa=0.78,split=2[logo][shadow_src];[shadow_src]colorchannelmixer=rr=0:gg=0:bb=0:aa=0.35[shadow];[0:v][shadow]overlay=x='0.382*W-w/2+2':y='H-h-0.05*H+2'[base];[base][logo]overlay=x='0.382*W-w/2':y='H-h-0.05*H'" \
  -frames:v 1 "$output_path"

ffprobe -v error -select_streams v:0 -show_entries stream=width,height,pix_fmt \
  -of default=nw=1 "$output_path"
