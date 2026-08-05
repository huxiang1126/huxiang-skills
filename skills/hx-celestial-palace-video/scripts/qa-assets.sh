#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 CLEAN_STILLS_DIRECTORY" >&2
  exit 64
fi

stills_dir="$1"
command -v ffmpeg >/dev/null || { echo "ffmpeg is required" >&2; exit 69; }
command -v ffprobe >/dev/null || { echo "ffprobe is required" >&2; exit 69; }
command -v shasum >/dev/null || { echo "shasum is required" >&2; exit 69; }
[[ -d "$stills_dir" ]] || { echo "Missing directory: $stills_dir" >&2; exit 66; }

found_count="$(find "$stills_dir" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) | wc -l | tr -d ' ')"
if [[ "$found_count" -ne 9 ]]; then
  echo "FAIL: expected exactly 9 still files, found $found_count" >&2
  exit 1
fi

failed=0
exact_hashes=()
normalized_hashes=()

for number in 01 02 03 04 05 06 07 08 09; do
  file="$stills_dir/S${number}_clean.png"
  if [[ ! -f "$file" ]]; then
    echo "FAIL: missing exact file S${number}_clean.png" >&2
    failed=1
    continue
  fi

  dimensions="$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$file")"
  width="${dimensions%x*}"
  height="${dimensions#*x}"
  if ! awk -v w="$width" -v h="$height" 'BEGIN { r=w/h; exit !(w >= 720 && h >= 1280 && r >= 0.5525 && r <= 0.5725) }'; then
    echo "FAIL dimensions/aspect: $file is ${width}x${height}" >&2
    failed=1
  else
    echo "OK: $(basename "$file") ${width}x${height}"
  fi

  exact_hash="$(shasum -a 256 "$file" | awk '{print $1}')"
  normalized_hash="$(ffmpeg -v error -i "$file" -vf 'scale=16:28,format=rgb24' -frames:v 1 -f rawvideo - | shasum -a 256 | awk '{print $1}')"

  for seen in "${exact_hashes[@]}"; do
    [[ "$exact_hash" != "$seen" ]] || { echo "FAIL exact duplicate: $(basename "$file")" >&2; failed=1; }
  done
  for seen in "${normalized_hashes[@]}"; do
    [[ "$normalized_hash" != "$seen" ]] || { echo "FAIL normalized visual duplicate: $(basename "$file")" >&2; failed=1; }
  done
  exact_hashes+=("$exact_hash")
  normalized_hashes+=("$normalized_hash")
done

exit "$failed"
