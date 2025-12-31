#!/usr/bin/env bash

source "$MXTP_ROOT_DIR/lib/pb.sh"
source "$MXTP_ROOT_DIR/lib/filesystem.sh"
source "$MXTP_ROOT_DIR/lib/format.sh"

ROOT_DIR="$MXTP_USER_ROOT_DIR/$1"
OUTPUT_DIR="$2"

TOTAL_FILES=$(get_count_files_ext "$ROOT_DIR/mxtp" "mp3")

processed_count=0

pb_init "$TOTAL_FILES" 30

while IFS= read -r -d '' file; do
  base="$(basename "$file")"

  cp "$file" "$OUTPUT_DIR/$base"
  ((processed_count++))

  label=$(truncate "$base")
  pb_update "$processed_count" "Moving: $label"
done < <(get_files_ext "$ROOT_DIR/mxtp" "mp3" | sort -z)

echo
echo "✔ Moving complete!"
