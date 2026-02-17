#!/usr/bin/env bash

# Processes a single audio file.
# This function handles the common logic for processing audio files,
# including converting to WAV, applying custom processing, and converting back to MP3.
#
# Args:
#   $1: The path to the input audio file.
#
# Returns:
#   0 on success, 1 on failure.
process_file() {
  local file="$1"
  local base="$(basename "$file")"
  local name="${base%.*}"
  local tmp_file="$output_dir/$name.tmp.wav"
  local output_file="$output_dir/$base"
  local failed=false

  if ! ffmpeg -nostdin -y -i "$file" -c:a pcm_s24le -ar 48000 -ac 2 "$tmp_file" >/dev/null 2>&1; then
    failed=true
  fi

  if ! $failed; then
    if ! custom_processing "$tmp_file"; then
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
    echo "FAILED:$base"
    return 1
  fi

  rm -f "$tmp_file"
  echo "SUCCESS:$base"
  return 0
}

# Custom processing function to be overridden by the caller.
# This function should contain the specific processing logic for the audio file.
#
# Args:
#   $1: The path to the temporary WAV file.
#
# Returns:
#   0 on success, 1 on failure.
custom_processing() {
  return 0
}

export -f process_file
export -f custom_processing
