#!/usr/bin/env bash

source "$MXTP_ROOT_DIR/lib/pb.sh"
source "$MXTP_ROOT_DIR/lib/filesystem.sh"
source "$MXTP_ROOT_DIR/lib/format.sh"

ROOT_DIR="$MXTP_USER_ROOT_DIR/$1"

TOTAL_FILES=$(get_count_files_ext "$ROOT_DIR" "mp3")

total_seconds=0
processed_count=0

if [[ "$3" != "--seconds" ]]; then
    pb_init "$TOTAL_FILES" 30
fi

while IFS= read -r -d '' file; do
    seconds=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file" 2>/dev/null)
    total_seconds=$(echo "$total_seconds + $seconds" | bc)

    if [[ "$3" != "--seconds" ]]; then
        ((processed_count++))

        label=$(basename "$file")
        label="$(truncate "$label")"
        pb_update "$processed_count" "Measuring: $label"
    fi

done < <(get_files_ext "$ROOT_DIR" "mp3")

if [[ "$3" == "--seconds" ]]; then
    echo "$total_seconds"
    exit 0
fi

echo
echo "✔ Total duration: $(from_seconds_to_duration "$total_seconds")"
