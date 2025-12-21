#!/bin/bash

source lib/pb.sh
source lib/filesystem.sh
source lib/gum.sh

ROOT_DIR="$MXTP_USER_ROOT_DIR/$1"
EXT=$2

TOTAL_FILES=$(get_count_files_ext "$ROOT_DIR" "$EXT")

success_count=0
fail_count=0
processed_count=0

failed_files=()

pb_init "$TOTAL_FILES" 30

while IFS= read -r -d '' file; do
    base="$(basename "$file")"
    name="${base%.*}"

    tmp_file="$ROOT_DIR/mxtp/$name.tmp.wav"
    output_file="$ROOT_DIR/mxtp/$base"

    failed=false

    if ! ffmpeg -nostdin -y -i "$file" \
        -af "loudnorm=I=-14:TP=-1.5:LRA=11" \
        -c:a pcm_s16le "$tmp_file" >/dev/null 2>&1; then
        failed=true
    fi

    if ! $failed; then
        if ! ffmpeg -nostdin -y -i "$tmp_file" \
            -codec:a libmp3lame -q:a 2 \
            "$output_file" >/dev/null 2>&1; then
            failed=true
        fi
    fi

    if $failed; then
        rm -f "$tmp_file"
        ((fail_count++))
        failed_files+=("$(basename "$file")")
        continue
    fi

    rm -f "$tmp_file"
    ((success_count++))
    ((processed_count++))

    label="$(basename "$file")"
    label="${label:0:40}"
    pb_update "$processed_count" "Normalizing: $label"
done < <(get_files_ext "$ROOT_DIR" "$EXT")

echo
echo "✔ Normalization complete!"

print_failed_files $fail_count "$TOTAL_FILES" "${failed_files[@]}"
