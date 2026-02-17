#!/usr/bin/env bash

source "$MXTP_ROOT_DIR/lib/pb.sh"
source "$MXTP_ROOT_DIR/lib/filesystem.sh"
source "$MXTP_ROOT_DIR/lib/cli.sh"
source "$MXTP_ROOT_DIR/lib/format.sh"
source "$MXTP_ROOT_DIR/lib/consts.sh"
source "$MXTP_ROOT_DIR/lib/logger.sh"
source "$MXTP_ROOT_DIR/lib/worker.sh"

ROOT_DIR="$(get_command_input_dir $1 $CHILD_DIR_NAME)"

output_dir="$ROOT_DIR"

if ! [[ "$ROOT_DIR" == *"$CHILD_DIR_NAME"* ]]; then
  mkdir -p "$ROOT_DIR/$CHILD_DIR_NAME"
  output_dir="$ROOT_DIR/$CHILD_DIR_NAME"
fi

TOTAL_FILES=$(get_count_files_ext "$ROOT_DIR" "mp3")

success_count=0
fail_count=0
processed_count=0

failed_files=()

before_seconds=$(bash "$MXTP_ROOT_DIR/commands/duration.sh" "$ROOT_DIR" "-s")

pb_init "$TOTAL_FILES" 30

# Override custom_processing for trimming
custom_processing() {
  local tmp_file="$1"

  if ! auto-editor "$tmp_file" \
    --edit audio \
    --output "$tmp_file" >/dev/null 2>&1; then
    return 1
  fi

  return 0
}

export output_dir
export -f custom_processing

# Determine the number of CPU cores
NUM_CORES=$(sysctl -n hw.ncpu)

# Process files in parallel using GNU Parallel
get_files_ext "$ROOT_DIR" "mp3" | parallel --will-cite -j "$NUM_CORES" -k --progress process_file

# Update progress and collect results
while IFS= read -r -d '' file; do
  base="$(basename "$file")"

  result=$(process_file "$file" 2>&1)

  if [[ "$result" == "SUCCESS:*" ]]; then
    ((success_count++))
  else
    ((fail_count++))
    failed_files+=("$base")
  fi

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

if [[ "$MXTP_ENV" == "test" ]]; then
  echo "{\"root_dir\": \"$ROOT_DIR\", \"output_dir\": \"$output_dir\"}" | jq .
  exit 0
fi

echo
echo "✔ Trimming complete! Saved $saved% space, from $before_fmt to $after_fmt"

print_failed_files $fail_count "$TOTAL_FILES" "${failed_files[@]}"
