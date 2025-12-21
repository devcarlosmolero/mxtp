#!/bin/bash

source "$MXTP_ROOT_DIR/lib/pb.sh"
source "$MXTP_ROOT_DIR/lib/filesystem.sh"
source "$MXTP_ROOT_DIR/lib/gum.sh"
source "$MXTP_ROOT_DIR/lib/format.sh"

ROOT_DIR="$MXTP_USER_ROOT_DIR/$1"
EXT=$2

TOTAL_FILES=$(get_count_files_ext "$ROOT_DIR" "$EXT")

success_count=0
fail_count=0
processed_count=0

failed_files=()

before_seconds=$(source commands/duration.sh "$1" "mp3" "--seconds")

pb_init "$TOTAL_FILES" 30

while IFS= read -r -d '' file; do
    base="$(basename "$file")"
    name="${base%.*}"

    tmp_file="$ROOT_DIR/mxtp/$name.tmp.wav"
    output_file="$ROOT_DIR/mxtp/$base"

    failed=false

    if ! ffmpeg -nostdin -y -i "$file" -c:a pcm_s16le "$tmp_file" >/dev/null 2>&1; then
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
            -codec:a libmp3lame -q:a 2 \
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

    label="${base:0:40}"
    pb_update "$processed_count" "Trimming: $label"
done < <(get_files_ext "$ROOT_DIR" "$EXT")

after_seconds=$(source commands/duration.sh "$1/mxtp" "mp3" "--seconds")

before_fmt=$(from_seconds_to_duration "$before_seconds")
after_fmt=$(from_seconds_to_duration "$after_seconds")

if [[ before_seconds -gt 0 ]]; then
    saved=$((100 - (after_seconds * 100 / before_seconds)))
else
    saved=0
fi

echo
echo "✔ Trimming complete! Saved $saved% space, from $before_fmt to $after_fmt"

print_failed_files $fail_count "$TOTAL_FILES" "${failed_files[@]}"
