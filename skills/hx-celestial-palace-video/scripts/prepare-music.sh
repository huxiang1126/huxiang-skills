#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 || $# -gt 4 ]]; then
  echo "Usage: $0 TARGET_SECONDS OUTPUT.m4a [INPUT_AUDIO] [START_SECONDS]" >&2
  exit 64
fi

target_seconds="$1"
output_path="$2"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="$(cd "$script_dir/.." && pwd)"
input_path="${3:-$skill_dir/assets/music/celestial-palace-theme.mp3}"
start_seconds="${4:-0}"

command -v ffmpeg >/dev/null || { echo "ffmpeg is required" >&2; exit 69; }
command -v ffprobe >/dev/null || { echo "ffprobe is required" >&2; exit 69; }
[[ -f "$input_path" ]] || { echo "Missing input audio: $input_path" >&2; exit 66; }
[[ "$output_path" == *.m4a ]] || { echo "Output must use the .m4a extension" >&2; exit 64; }

source_seconds="$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$input_path")"
awk -v t="$target_seconds" -v o="$start_seconds" -v s="$source_seconds" 'BEGIN { if (t <= 2 || o < 0 || o+t > s) exit 1 }' || {
  echo "START_SECONDS + TARGET_SECONDS must fit inside source duration ($source_seconds)" >&2
  exit 65
}

fade_in="0.6"
fade_out="1.5"
fade_out_start="$(awk -v t="$target_seconds" -v f="$fade_out" 'BEGIN { printf "%.3f", t-f }')"
mkdir -p "$(dirname "$output_path")"

ffmpeg -y -hide_banner -loglevel error \
  -ss "$start_seconds" -i "$input_path" -t "$target_seconds" \
  -af "loudnorm=I=-18:LRA=11:TP=-1.5,afade=t=in:st=0:d=$fade_in,afade=t=out:st=$fade_out_start:d=$fade_out" \
  -c:a aac -b:a 192k -ar 48000 "$output_path"

ffprobe -v error -show_entries format=duration:stream=codec_name,sample_rate,channels \
  -of default=nw=1 "$output_path"
