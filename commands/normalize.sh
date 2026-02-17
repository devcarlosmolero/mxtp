#!/usr/bin/env bash

source "$MXTP_ROOT_DIR/lib/pb.sh"
source "$MXTP_ROOT_DIR/lib/filesystem.sh"
source "$MXTP_ROOT_DIR/lib/cli.sh"
source "$MXTP_ROOT_DIR/lib/consts.sh"
source "$MXTP_ROOT_DIR/lib/format.sh"
source "$MXTP_ROOT_DIR/lib/worker.sh"

ROOT_DIR="$(get_command_input_dir $1 $CHILD_DIR_NAME)"
FFMPEG_OPTS=${2:-"loudnorm=I=-14:TP=-3:LRA=10"}

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

pb_init "$TOTAL_FILES" 30

# Override custom_processing for normalization
custom_processing() {
  local tmp_file="$1"
  local loudnorm_stats=$(ffmpeg -nostdin -y -i "$file" \
    -af "$FFMPEG_OPTS:print_format=json" \
    -f null - 2>&1)

  if [[ -z "$loudnorm_stats" ]]; then
    return 1
  else
    local input_i=$(echo "$loudnorm_stats" | grep '"input_i"' | sed 's/[^0-9.\-]//g')
    local input_tp=$(echo "$loudnorm_stats" | grep '"input_tp"' | sed 's/[^0-9.\-]//g')
    local input_lra=$(echo "$loudnorm_stats" | grep '"input_lra"' | sed 's/[^0-9.\-]//g')
    local input_thresh=$(echo "$loudnorm_stats" | grep '"input_thresh"' | sed 's/[^0-9.\-]//g')
    local offset=$(echo "$loudnorm_stats" | grep '"target_offset"' | sed 's/[^0-9.\-]//g')

    if ! ffmpeg -nostdin -y -i "$file" -af "$FFMPEG_OPTS:measured_I=$input_i:measured_TP=$input_tp:measured_LRA=$input_lra:measured_thresh=$input_thresh:offset=$offset" \
      -c:a pcm_s24le -ar 48000 -ac 2 "$tmp_file" >/dev/null 2>&1; then
      return 1
    fi
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
  pb_update "$processed_count" "Normalizing: $label"
done < <(get_files_ext "$ROOT_DIR" "mp3")

if [[ "$MXTP_ENV" == "test" ]]; then
  echo "{\"root_dir\": \"$ROOT_DIR\", \"output_dir\": \"$output_dir\", \"ffmpeg_opts\": \"$FFMPEG_OPTS\"}" | jq .
  exit 0
fi

echo
echo "✔ Normalization complete!"

print_failed_files $fail_count "$TOTAL_FILES" "${failed_files[@]}"
