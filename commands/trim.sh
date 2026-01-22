#!/usr/bin/env bash

source "$MXTP_ROOT_DIR/lib/pb.sh"
source "$MXTP_ROOT_DIR/lib/filesystem.sh"
source "$MXTP_ROOT_DIR/lib/cli.sh"
source "$MXTP_ROOT_DIR/lib/format.sh"
source "$MXTP_ROOT_DIR/lib/consts.sh"

ROOT_DIR="$(get_command_input_dir $1 $CHILD_DIR_NAME)"

if ! [[ "$ROOT_DIR" == *"$CHILD_DIR_NAME"* ]]; then
  mkdir "$ROOT_DIR/$CHILD_DIR_NAME"
fi

TOTAL_FILES=$(get_count_files_ext "$ROOT_DIR" "mp3")

success_count=0
fail_count=0
processed_count=0

failed_files=()

before_seconds=$(bash "$MXTP_ROOT_DIR/commands/duration.sh" "$ROOT_DIR" "-s")

pb_init "$TOTAL_FILES" 30

while IFS= read -r -d '' file; do
  base="$(basename "$file")"
  name="${base%.*}"

  tmp_file="$ROOT_DIR/$CHILD_DIR_NAME/$name.tmp.wav"
  output_file="$ROOT_DIR/$CHILD_DIR_NAME/$base"

  failed=false

  if ! ffmpeg -nostdin -y -i "$file" -c:a pcm_s24le -ar 48000 -ac 2 "$tmp_file" >/dev/null 2>&1; then
    failed=true
  fi

  if ! $failed; then
    if ! auto-editor "$tmp_file" \
      --edit audio \
      --output "$tmp_file" >/dev/null 2>&1; then
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
    ((fail_count++))
    failed_files+=("$base")
    rm -f "$tmp_file"
    continue
  fi

  rm -f "$tmp_file"
  ((success_count++))
  ((processed_count++))

  label=$(truncate "$base")
  pb_update "$processed_count" "Trimming: $label"
done < <(get_files_ext "$ROOT_DIR" "mp3")

after_seconds=$(source "$MXTP_ROOT_DIR/commands/duration.sh" "$1/$CHILD_DIR_NAME" "-s")

before_fmt=$(from_seconds_to_duration "$before_seconds")
after_fmt=$(from_seconds_to_duration "$after_seconds")

if (($(echo "$before_seconds > 0" | bc -l))); then
  saved=$(echo "scale=2; 100 - ($after_seconds * 100 / $before_seconds)" | bc)
else
  saved=0
fi

echo
echo "✔ Trimming complete! Saved $saved% space, from $before_fmt to $after_fmt"

print_failed_files $fail_count "$TOTAL_FILES" "${failed_files[@]}"
