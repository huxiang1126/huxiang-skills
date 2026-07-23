#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <approved-still> <RRGGBB> <output-dir>" >&2
  exit 2
fi

still_path=$1
background_hex=${2#\#}
output_dir=$3

if [[ ! -f "$still_path" ]]; then
  echo "Approved still not found: $still_path" >&2
  exit 1
fi

if [[ ! "$background_hex" =~ ^[0-9A-Fa-f]{6}$ ]]; then
  echo "Background color must be a six-digit hex value: RRGGBB" >&2
  exit 2
fi

if [[ -e "$output_dir/first-frame.png" || -e "$output_dir/last-frame.png" ]]; then
  echo "Refusing to overwrite existing frames; use a new versioned output directory: $output_dir" >&2
  exit 1
fi
mkdir -p "$output_dir"

ffmpeg -hide_banner -loglevel error -y \
  -i "$still_path" \
  -vf "scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920" \
  "$output_dir/last-frame.png"

ffmpeg -hide_banner -loglevel error -y \
  -f lavfi -i "color=c=0x${background_hex}:s=1080x1920" \
  -frames:v 1 \
  "$output_dir/first-frame.png"

echo "$output_dir/first-frame.png"
echo "$output_dir/last-frame.png"
