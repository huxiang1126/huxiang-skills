#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 || $# -gt 3 ]]; then
  echo "Usage: $0 <whoosh|paper|impact|click|camera|sparkle> <output.wav> [duration]" >&2
  exit 2
fi

sfx_type=$1
output_path=$2
duration=${3:-0.35}

if ! awk -v value="$duration" 'BEGIN { exit !(value >= 0.05 && value <= 5) }'; then
  echo "Duration must be between 0.05 and 5 seconds" >&2
  exit 2
fi
if [[ -e "$output_path" ]]; then
  echo "Refusing to overwrite existing SFX; choose a new versioned path: $output_path" >&2
  exit 1
fi

fade_in=$(awk -v value="$duration" 'BEGIN { v=value*0.12; if (v>0.04) v=0.04; printf "%.5f", v }')
fade_out=$(awk -v value="$duration" 'BEGIN { v=value*0.45; if (v>0.25) v=0.25; printf "%.5f", v }')
fade_out_start=$(awk -v value="$duration" -v fade="$fade_out" 'BEGIN { printf "%.5f", value-fade }')

case "$sfx_type" in
  whoosh)
    source="anoisesrc=color=pink:amplitude=0.35:duration=${duration}:sample_rate=48000"
    filter="highpass=f=250,lowpass=f=6500,afade=t=in:st=0:d=${fade_in},afade=t=out:st=${fade_out_start}:d=${fade_out},volume=0.8"
    ;;
  paper)
    source="anoisesrc=color=white:amplitude=0.16:duration=${duration}:sample_rate=48000"
    filter="highpass=f=1100,lowpass=f=9000,tremolo=f=17:d=0.55,afade=t=in:st=0:d=${fade_in},afade=t=out:st=${fade_out_start}:d=${fade_out},volume=0.75"
    ;;
  impact)
    source="sine=frequency=92:duration=${duration}:sample_rate=48000"
    filter="lowpass=f=420,afade=t=out:st=${fade_out_start}:d=${fade_out},volume=0.9"
    ;;
  click)
    source="sine=frequency=1750:duration=${duration}:sample_rate=48000"
    filter="highpass=f=900,afade=t=out:st=${fade_out_start}:d=${fade_out},volume=0.45"
    ;;
  camera)
    source="anoisesrc=color=white:amplitude=0.20:duration=${duration}:sample_rate=48000"
    filter="highpass=f=700,lowpass=f=5000,tremolo=f=24:d=0.85,afade=t=out:st=${fade_out_start}:d=${fade_out},volume=0.65"
    ;;
  sparkle)
    source="sine=frequency=2400:duration=${duration}:sample_rate=48000"
    filter="aecho=0.8:0.45:35|70:0.35|0.18,highpass=f=1200,afade=t=out:st=${fade_out_start}:d=${fade_out},volume=0.35"
    ;;
  *)
    echo "Unknown SFX type: $sfx_type" >&2
    exit 2
    ;;
esac

mkdir -p "$(dirname "$output_path")"

ffmpeg -hide_banner -loglevel error -y \
  -f lavfi -i "$source" -af "$filter" -t "$duration" \
  -ar 48000 -ac 1 -c:a pcm_s16le "$output_path"

echo "$output_path"
