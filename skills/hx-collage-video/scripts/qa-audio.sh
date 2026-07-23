#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 && $# -ne 6 ]]; then
  echo "Usage: $0 <no-music-master.mp4> <audio-manifest.json> <output-dir> [music-master.mp4 bgm-stem music-credit.md]" >&2
  exit 2
fi

no_music_master=$1
audio_manifest=$2
output_dir=$3
music_master=${4:-}
bgm_stem=${5:-}
music_credit=${6:-}

for required_file in "$no_music_master" "$audio_manifest"; do
  if [[ ! -s "$required_file" ]]; then
    echo "Required file is missing or empty: $required_file" >&2
    exit 1
  fi
done
if [[ -e "$output_dir/audio-qa.json" || -e "$output_dir/audio-qa.md" ]]; then
  echo "Refusing to overwrite existing audio QA; choose a new versioned output directory: $output_dir" >&2
  exit 1
fi
if ! jq -e '.version == "2.3.0" and (.background_music_authorized | type == "boolean") and (.tracks | type == "array") and (.mixes.no_music | type == "array") and (.reference_mixes.no_music.path | type == "string") and (.reference_mixes.no_music.sha256 | type == "string")' "$audio_manifest" >/dev/null; then
  echo "Audio manifest does not match the v2.3 base contract: $audio_manifest" >&2
  exit 1
fi
if ! ffprobe -v error -show_format -show_streams -of json "$no_music_master" >/dev/null; then
  echo "No-music master is not decodable: $no_music_master" >&2
  exit 1
fi

mkdir -p "$output_dir"
manifest_dir=$(cd "$(dirname "$audio_manifest")" && pwd)
audio_errors=0

resolve_track_path() {
  local declared_path=$1
  if [[ "$declared_path" = /* ]]; then
    printf '%s\n' "$declared_path"
  else
    printf '%s\n' "$manifest_dir/$declared_path"
  fi
}

while IFS=$'\t' read -r track_id track_kind track_path declared_hash; do
  resolved_path=$(resolve_track_path "$track_path")
  if [[ ! -s "$resolved_path" ]]; then
    echo "Audio track is missing: $track_id -> $resolved_path" >&2
    audio_errors=$((audio_errors + 1))
    continue
  fi
  if ! ffprobe -v error -select_streams a:0 -show_entries stream=codec_type -of csv=p=0 "$resolved_path" | grep -qx audio; then
    echo "Track is not decodable audio: $track_id -> $resolved_path" >&2
    audio_errors=$((audio_errors + 1))
    continue
  fi
  actual_hash=$(shasum -a 256 "$resolved_path" | awk '{print $1}')
  if [[ "$actual_hash" != "$declared_hash" ]]; then
    echo "Track hash mismatch: $track_id" >&2
    audio_errors=$((audio_errors + 1))
  fi
done < <(jq -r '.tracks[] | [.id, .kind, .path, .sha256] | @tsv' "$audio_manifest")

no_music_reference=$(resolve_track_path "$(jq -r '.reference_mixes.no_music.path' "$audio_manifest")")
declared_no_music_reference_hash=$(jq -r '.reference_mixes.no_music.sha256' "$audio_manifest")
if [[ ! -s "$no_music_reference" ]] || ! ffprobe -v error -select_streams a:0 -show_entries stream=codec_type -of csv=p=0 "$no_music_reference" | grep -qx audio; then
  echo "No-music reference mix is missing or not decodable: $no_music_reference" >&2
  audio_errors=$((audio_errors + 1))
else
  actual_no_music_reference_hash=$(shasum -a 256 "$no_music_reference" | awk '{print $1}')
  if [[ "$actual_no_music_reference_hash" != "$declared_no_music_reference_hash" ]]; then
    echo "No-music reference mix hash mismatch" >&2
    audio_errors=$((audio_errors + 1))
  fi
fi

while IFS= read -r mix_track_id; do
  kind=$(jq -r --arg id "$mix_track_id" '.tracks[] | select(.id == $id) | .kind' "$audio_manifest")
  if [[ -z "$kind" ]]; then
    echo "No-music mix references unknown track: $mix_track_id" >&2
    audio_errors=$((audio_errors + 1))
  elif [[ "$kind" == "bgm" ]]; then
    echo "No-music mix illegally includes BGM track: $mix_track_id" >&2
    audio_errors=$((audio_errors + 1))
  fi
done < <(jq -r '.mixes.no_music[]' "$audio_manifest")

ffprobe -v error -show_streams -show_format -of json "$no_music_master" > "$output_dir/no-music-metadata.json"
master_audio_streams=$(jq '[.streams[] | select(.codec_type == "audio")] | length' "$output_dir/no-music-metadata.json")
master_video_streams=$(jq '[.streams[] | select(.codec_type == "video")] | length' "$output_dir/no-music-metadata.json")
master_sample_rate=$(jq -r '[.streams[] | select(.codec_type == "audio")][0].sample_rate // "0"' "$output_dir/no-music-metadata.json")
master_channels=$(jq -r '[.streams[] | select(.codec_type == "audio")][0].channels // 0' "$output_dir/no-music-metadata.json")
if [[ "$master_audio_streams" -ne 1 || "$master_video_streams" -ne 1 || "$master_sample_rate" != "48000" || "$master_channels" -ne 2 ]]; then
  echo "No-music master must contain one video stream and one 48kHz stereo audio stream" >&2
  audio_errors=$((audio_errors + 1))
fi

ffmpeg -hide_banner -i "$no_music_master" -map 0:a:0 -af volumedetect -f null - >"$output_dir/no-music-volume.log" 2>&1
no_music_mean=$(awk '/mean_volume:/ {print $(NF-1)}' "$output_dir/no-music-volume.log" | tail -1)
no_music_peak=$(awk '/max_volume:/ {print $(NF-1)}' "$output_dir/no-music-volume.log" | tail -1)
if [[ -z "$no_music_peak" ]] || ! awk -v peak="$no_music_peak" 'BEGIN { exit !(peak <= -0.1) }'; then
  echo "No-music master is clipped or peak could not be measured: ${no_music_peak:-unknown} dB" >&2
  audio_errors=$((audio_errors + 1))
fi
ffmpeg -v error -i "$no_music_master" -f null -

no_music_sdr=""
if [[ -s "$no_music_reference" ]]; then
  ffmpeg -hide_banner -i "$no_music_master" -i "$no_music_reference" \
    -filter_complex "[0:a]aresample=48000,aformat=channel_layouts=stereo[a0];[1:a]aresample=48000,aformat=channel_layouts=stereo[a1];[a0][a1]asdr" \
    -f null - >"$output_dir/no-music-reference-compare.log" 2>&1
  no_music_sdr=$(awk '/SDR ch[0-9]+:/ {for (field=1; field<=NF; field++) if ($field=="dB") print $(field-1)}' "$output_dir/no-music-reference-compare.log" | sort -n | head -1)
  if [[ -z "$no_music_sdr" ]] || ! awk -v value="$no_music_sdr" 'BEGIN { exit !(value == "inf" || value + 0 >= 20) }'; then
    echo "No-music master audio does not match the declared reference mix closely enough: ${no_music_sdr:-unknown} dB SDR" >&2
    audio_errors=$((audio_errors + 1))
  fi
fi

no_music_video_hash=$(ffmpeg -hide_banner -loglevel error -i "$no_music_master" -map 0:v:0 -c copy -f md5 - | sed 's/^MD5=//')
no_music_audio_hash=$(ffmpeg -hide_banner -loglevel error -i "$no_music_master" -map 0:a:0 -c copy -f md5 - | sed 's/^MD5=//')

music_verdict=NOT_REQUESTED
music_mean=""
music_peak=""
music_video_hash=""
music_audio_hash=""
music_sdr=""
if [[ -n "$music_master" ]]; then
  music_verdict=PASS
  for required_file in "$music_master" "$bgm_stem" "$music_credit"; do
    if [[ ! -s "$required_file" ]]; then
      echo "Music delivery file is missing or empty: $required_file" >&2
      music_verdict=FAIL
      audio_errors=$((audio_errors + 1))
    fi
  done
  if [[ "$(jq -r '.background_music_authorized' "$audio_manifest")" != "true" ]]; then
    echo "Music master exists but background_music_authorized is not true" >&2
    music_verdict=FAIL
    audio_errors=$((audio_errors + 1))
  fi
  if [[ -s "$music_master" ]]; then
    ffmpeg -v error -i "$music_master" -f null -
    ffmpeg -hide_banner -i "$music_master" -map 0:a:0 -af volumedetect -f null - >"$output_dir/music-volume.log" 2>&1
    music_mean=$(awk '/mean_volume:/ {print $(NF-1)}' "$output_dir/music-volume.log" | tail -1)
    music_peak=$(awk '/max_volume:/ {print $(NF-1)}' "$output_dir/music-volume.log" | tail -1)
    if [[ -z "$music_peak" ]] || ! awk -v peak="$music_peak" 'BEGIN { exit !(peak <= -0.1) }'; then
      echo "Music master is clipped or peak could not be measured: ${music_peak:-unknown} dB" >&2
      music_verdict=FAIL
      audio_errors=$((audio_errors + 1))
    fi
    music_video_hash=$(ffmpeg -hide_banner -loglevel error -i "$music_master" -map 0:v:0 -c copy -f md5 - | sed 's/^MD5=//')
    music_audio_hash=$(ffmpeg -hide_banner -loglevel error -i "$music_master" -map 0:a:0 -c copy -f md5 - | sed 's/^MD5=//')
    if [[ "$music_video_hash" != "$no_music_video_hash" ]]; then
      echo "Music and no-music masters do not share the same video stream" >&2
      music_verdict=FAIL
      audio_errors=$((audio_errors + 1))
    fi
    if [[ "$music_audio_hash" == "$no_music_audio_hash" ]]; then
      echo "Music and no-music masters have identical audio streams" >&2
      music_verdict=FAIL
      audio_errors=$((audio_errors + 1))
    fi
    music_reference=$(resolve_track_path "$(jq -r '.reference_mixes.music.path // ""' "$audio_manifest")")
    declared_music_reference_hash=$(jq -r '.reference_mixes.music.sha256 // ""' "$audio_manifest")
    if [[ ! -s "$music_reference" ]] || ! ffprobe -v error -select_streams a:0 -show_entries stream=codec_type -of csv=p=0 "$music_reference" | grep -qx audio; then
      echo "Music reference mix is missing or not decodable: $music_reference" >&2
      music_verdict=FAIL
      audio_errors=$((audio_errors + 1))
    else
      actual_music_reference_hash=$(shasum -a 256 "$music_reference" | awk '{print $1}')
      if [[ "$actual_music_reference_hash" != "$declared_music_reference_hash" ]]; then
        echo "Music reference mix hash mismatch" >&2
        music_verdict=FAIL
        audio_errors=$((audio_errors + 1))
      fi
      ffmpeg -hide_banner -i "$music_master" -i "$music_reference" \
        -filter_complex "[0:a]aresample=48000,aformat=channel_layouts=stereo[a0];[1:a]aresample=48000,aformat=channel_layouts=stereo[a1];[a0][a1]asdr" \
        -f null - >"$output_dir/music-reference-compare.log" 2>&1
      music_sdr=$(awk '/SDR ch[0-9]+:/ {for (field=1; field<=NF; field++) if ($field=="dB") print $(field-1)}' "$output_dir/music-reference-compare.log" | sort -n | head -1)
      if [[ -z "$music_sdr" ]] || ! awk -v value="$music_sdr" 'BEGIN { exit !(value == "inf" || value + 0 >= 20) }'; then
        echo "Music master audio does not match the declared reference mix closely enough: ${music_sdr:-unknown} dB SDR" >&2
        music_verdict=FAIL
        audio_errors=$((audio_errors + 1))
      fi
    fi
  fi
  if [[ -s "$bgm_stem" ]] && ! ffprobe -v error -select_streams a:0 -show_entries stream=codec_type -of csv=p=0 "$bgm_stem" | grep -qx audio; then
    echo "BGM stem is not decodable audio: $bgm_stem" >&2
    music_verdict=FAIL
    audio_errors=$((audio_errors + 1))
  fi
fi

overall_verdict=PASS
if [[ "$audio_errors" -ne 0 ]]; then overall_verdict=FAIL; fi

cat > "$output_dir/audio-qa.md" <<EOF
# Audio QA v2.3

- Verdict: ${overall_verdict}
- No-music master mean volume: ${no_music_mean:-unknown} dB
- No-music master peak: ${no_music_peak:-unknown} dB
- No-music reference SDR: ${no_music_sdr:-unknown} dB
- No-music video hash: ${no_music_video_hash}
- No-music audio hash: ${no_music_audio_hash}
- Music delivery verdict: ${music_verdict}
- Music master mean volume: ${music_mean:-not measured} dB
- Music master peak: ${music_peak:-not measured} dB
- Music reference SDR: ${music_sdr:-not measured} dB
- Music video hash: ${music_video_hash:-not measured}
- Music audio hash: ${music_audio_hash:-not measured}
- Manifest forensic errors: ${audio_errors}

This check validates decodability, declared stem hashes, no-BGM membership in the no-music mix, master-to-reference audio similarity, peak headroom, and dual-master stream separation. It does not classify music by listening. A human must still listen through the final masters for pronunciation, synchronization, ducking, noise, and perceptual mix errors.
EOF

jq -n \
  --arg version "2.3.0" \
  --arg verdict "$overall_verdict" \
  --arg musicVerdict "$music_verdict" \
  --arg noMusicVideoHash "$no_music_video_hash" \
  --arg noMusicAudioHash "$no_music_audio_hash" \
  --arg musicVideoHash "$music_video_hash" \
  --arg musicAudioHash "$music_audio_hash" \
  --arg noMusicReferenceSdr "$no_music_sdr" \
  --arg musicReferenceSdr "$music_sdr" \
  --argjson errors "$audio_errors" \
  '{version:$version, verdict:$verdict, musicVerdict:$musicVerdict, hashes:{noMusicVideo:$noMusicVideoHash,noMusicAudio:$noMusicAudioHash,musicVideo:$musicVideoHash,musicAudio:$musicAudioHash},referenceSdr:{noMusic:$noMusicReferenceSdr,music:$musicReferenceSdr},errors:$errors}' \
  > "$output_dir/audio-qa.json"

echo "$output_dir/audio-qa.md"
if [[ "$overall_verdict" != "PASS" ]]; then exit 1; fi
