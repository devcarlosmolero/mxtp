#!/usr/bin/env bash

source "$MXTP_ROOT_DIR/lib/pb.sh"
source "$MXTP_ROOT_DIR/lib/filesystem.sh"
source "$MXTP_ROOT_DIR/lib/cli.sh"
source "$MXTP_ROOT_DIR/lib/consts.sh"
source "$MXTP_ROOT_DIR/lib/format.sh"

ROOT_DIR="$(get_command_input_dir $1 $CHILD_DIR_NAME)"
FFMPEG_OPTS="$2"

output_dir="$ROOT_DIR"

if ! [[ "$ROOT_DIR" == *"$CHILD_DIR_NAME"* ]]; then
  mkdir "$ROOT_DIR/$CHILD_DIR_NAME"
  output_dir="$ROOT_DIR/$CHILD_DIR_NAME"
fi

TOTAL_FILES=$(get_count_files_ext "$ROOT_DIR" "mp3")

success_count=0
fail_count=0
processed_count=0

failed_files=()

pb_init "$TOTAL_FILES" 30

while IFS= read -r -d '' file; do
  base="$(basename "$file")"
  name="${base%.*}"

  tmp_file="$output_dir/$name.tmp.wav"
  output_file="$output_dir/$base"

  failed=false

  loudnorm_stats=$(ffmpeg -nostdin -y -i "$file" \
    -af "loudnorm=I=-14:TP=-3:LRA=10:print_format=json" \
    -f null - 2>&1)

  if [[ -z "$loudnorm_stats" ]]; then
    failed=true
  else
    input_i=$(echo "$loudnorm_stats" | grep '"input_i"' | sed 's/[^0-9.\-]//g')
    input_tp=$(echo "$loudnorm_stats" | grep '"input_tp"' | sed 's/[^0-9.\-]//g')
    input_lra=$(echo "$loudnorm_stats" | grep '"input_lra"' | sed 's/[^0-9.\-]//g')
    input_thresh=$(echo "$loudnorm_stats" | grep '"input_thresh"' | sed 's/[^0-9.\-]//g')
    offset=$(echo "$loudnorm_stats" | grep '"target_offset"' | sed 's/[^0-9.\-]//g')

    if ! ffmpeg -nostdin -y -i "$file" \
      -af "loudnorm=I=-14:TP=-3:LRA=10:measured_I=$input_i:measured_TP=$input_tp:measured_LRA=$input_lra:measured_thresh=$input_thresh:offset=$offset" \
      -c:a pcm_s24le -ar 48000 -ac 2 "$tmp_file" >/dev/null 2>&1; then
      failed=true
    fi
  fi

  if ! $failed; then
    if ! ffmpeg -nostdin -y -i "$tmp_file" \
      -codec:a libmp3lame -b:a 320k \
      "$output_file" >/dev/null 2>&1; then
      failed=true
    fi
  fi

  if $failed; then
    rm -f "$tmp_file"
    ((fail_count++))
    failed_files+=("$base")
    continue
  fi

  rm -f "$tmp_file"
  ((success_count++))
  ((processed_count++))

  label=$(truncate "$base")
  pb_update "$processed_count" "Normalizing: $label"
done < <(get_files_ext "$ROOT_DIR" "mp3")

# testing
if [[ "$MXTP_ENV" == "test" ]]; then
  echo "{\"root_dir\": \"$ROOT_DIR\", \"output_dir\": \"$output_dir\"}" | jq .
  exit 0
fi

echo "✔ Normalization complete!"

print_failed_files $fail_count "$TOTAL_FILES" "${failed_files[@]}"
