#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 FINAL_VIDEO.mp4 EXPECTED_SECONDS ACCEPTED_CLIPS_DIRECTORY" >&2
  exit 64
fi

video_path="$1"
expected_seconds="$2"
accepted_dir="$3"
command -v ffmpeg >/dev/null || { echo "ffmpeg is required" >&2; exit 69; }
command -v ffprobe >/dev/null || { echo "ffprobe is required" >&2; exit 69; }
command -v shasum >/dev/null || { echo "shasum is required" >&2; exit 69; }
[[ -f "$video_path" ]] || { echo "Missing video: $video_path" >&2; exit 66; }
[[ -d "$accepted_dir" ]] || { echo "Missing accepted clips directory: $accepted_dir" >&2; exit 66; }

width="$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 "$video_path")"
height="$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$video_path")"
fps_ratio="$(ffprobe -v error -select_streams v:0 -show_entries stream=avg_frame_rate -of csv=p=0 "$video_path")"
duration="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$video_path")"
audio_count="$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$video_path" | wc -l | tr -d ' ')"
fps_value="$(awk -F/ -v r="$fps_ratio" 'BEGIN { split(r,a,"/"); if (a[2] == 0 || a[2] == "") print a[1]; else printf "%.6f", a[1]/a[2] }')"

echo "video=$video_path"
echo "size=${width}x${height}"
echo "fps=$fps_ratio"
echo "duration=$duration"
echo "audio_streams=$audio_count"

failed=0
[[ "$width" == "1080" && "$height" == "1920" ]] || { echo "FAIL: expected 1080x1920" >&2; failed=1; }
awk -v f="$fps_value" 'BEGIN { exit !(f >= 29.9 && f <= 30.1) }' || { echo "FAIL: expected approximately 30 fps" >&2; failed=1; }
awk -v d="$duration" -v e="$expected_seconds" 'BEGIN { delta=d-e; if (delta<0) delta=-delta; exit !(d > 1 && delta <= 0.35) }' || { echo "FAIL: duration differs from expected by more than 0.35s" >&2; failed=1; }
[[ "$audio_count" -ge 1 ]] || { echo "FAIL: no audio stream" >&2; failed=1; }

clip_count="$(find "$accepted_dir" -maxdepth 1 -type f -name 'S??_veo.mp4' | wc -l | tr -d ' ')"
[[ "$clip_count" -eq 9 ]] || { echo "FAIL: expected 9 accepted clips, found $clip_count" >&2; failed=1; }

accepted_hashes=()
qa_dir="${video_path%.*}_qa"
mkdir -p "$qa_dir/samples" "$qa_dir/boundaries"

for number in 01 02 03 04 05 06 07 08 09; do
  clip="$accepted_dir/S${number}_veo.mp4"
  if [[ ! -f "$clip" ]]; then
    echo "FAIL: missing S${number}_veo.mp4" >&2
    failed=1
    continue
  fi
  clip_duration="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$clip")" || { echo "FAIL: cannot probe $clip" >&2; failed=1; continue; }
  clip_hash="$(shasum -a 256 "$clip" | awk '{print $1}')"
  for seen in "${accepted_hashes[@]}"; do
    [[ "$clip_hash" != "$seen" ]] || { echo "FAIL exact duplicate accepted clip: S${number}_veo.mp4" >&2; failed=1; }
  done
  accepted_hashes+=("$clip_hash")
  midpoint="$(awk -v d="$clip_duration" 'BEGIN { printf "%.3f", d/2 }')"
  endpoint="$(awk -v d="$clip_duration" 'BEGIN { e=d-0.05; if (e<0) e=0; printf "%.3f", e }')"
  ffmpeg -y -hide_banner -loglevel error -ss 0 -i "$clip" -frames:v 1 "$qa_dir/boundaries/S${number}_start.jpg" || { echo "FAIL decode start: $clip" >&2; failed=1; }
  ffmpeg -y -hide_banner -loglevel error -ss "$midpoint" -i "$clip" -frames:v 1 "$qa_dir/boundaries/S${number}_mid.jpg" || { echo "FAIL decode midpoint: $clip" >&2; failed=1; }
  ffmpeg -y -hide_banner -loglevel error -ss "$endpoint" -i "$clip" -frames:v 1 "$qa_dir/boundaries/S${number}_end.jpg" || { echo "FAIL decode end: $clip" >&2; failed=1; }
done

ffmpeg -y -hide_banner -loglevel error -i "$video_path" -vf fps=1 "$qa_dir/samples/sample_%03d.jpg" || { echo "FAIL: could not export 1fps samples" >&2; failed=1; }
black_report="$(ffmpeg -hide_banner -loglevel info -i "$video_path" -vf 'blackdetect=d=0.2:pix_th=0.10' -an -f null - 2>&1 | grep 'black_' || true)"
printf '%s\n' "$black_report" > "$qa_dir/blackdetect.txt"
if [[ -n "$black_report" ]]; then
  echo "FAIL: black interval >=0.2s detected; see $qa_dir/blackdetect.txt" >&2
  failed=1
fi

echo "qa_frames=$qa_dir"
echo "Manual review remains required to prove all nine scenes and watermark-safe composition."
exit "$failed"
