#!/usr/bin/env bash

PARENT_DIR="$(pwd)/commands-test"
MOVE_DIR="$PARENT_DIR/mv"

function set_up() {
  local _duration=5
  local _songs=("song1" "song2" "song3")

  mkdir $PARENT_DIR
  mkdir $MOVE_DIR

  for song in "${_songs[@]}"; do
    ffmpeg -nostdin -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 -t "$_duration" -q:a 9 -acodec libmp3lame "$PARENT_DIR/$song.mp3" >/dev/null 2>&1
  done

  source "$MXTP_ROOT_DIR/lib/consts.sh"
}

function test_commands_command_duration_output() {
  local _output

  _output=$(bash $MXTP_ROOT_DIR/commands/duration.sh $PARENT_DIR | sed -n '/^{/,/}$/p')

  assert_exit_code 0
  assert_equals "$PARENT_DIR" "$(echo "$_output" | jq -r '.root_dir')"
  assert_equals "15s" "$(echo "$_output" | jq -r '.total_duration')"
}

function test_commands_command_trim_output() {
  local _output

  _output=$(bash $MXTP_ROOT_DIR/commands/trim.sh $PARENT_DIR | sed -n '/^{/,/}$/p')

  assert_exit_code 0
  assert_equals "$PARENT_DIR" "$(echo "$_output" | jq -r '.root_dir')"
  assert_equals "$PARENT_DIR/$CHILD_DIR_NAME" "$(echo "$_output" | jq -r '.output_dir')"
}

function test_commands_command_normalize_output() {
  local _output

  _output=$(bash $MXTP_ROOT_DIR/commands/normalize.sh $PARENT_DIR | sed -n '/^{/,/}$/p')

  assert_exit_code 0
  assert_equals "$PARENT_DIR" "$(echo "$_output" | jq -r '.root_dir')"
  assert_equals "$PARENT_DIR/$CHILD_DIR_NAME" "$(echo "$_output" | jq -r '.output_dir')"
}

function test_commands_command_reorganize_output() {
  local _output

  _output=$(bash $MXTP_ROOT_DIR/commands/reorganize.sh $PARENT_DIR 46 | sed -n '/^{/,/}$/p')

  assert_exit_code 0
  assert_equals "$PARENT_DIR" "$(echo "$_output" | jq -r '.root_dir')"
  assert_equals "$PARENT_DIR/$CHILD_DIR_NAME" "$(echo "$_output" | jq -r '.output_dir')"
  assert_equals "false" "$(echo "$_output" | jq -r '.should_remove_after_rename')"
  assert_equals "46" "$(echo "$_output" | jq -r '.cassette_minutes')"

  _output=$(find "$PARENT_DIR/$CHILD_DIR_NAME" -maxdepth 1 -type f | wc -l | xargs)

  assert_exit_code 0
  assert_equals "5" "$_output"
}

function test_commands_command_move_output() {
  local _output

  bash $MXTP_ROOT_DIR/commands/move.sh $PARENT_DIR $MOVE_DIR 2>&1

  assert_exit_code 0

  _output=$(find $MOVE_DIR -maxdepth 1 -type f | wc -l | xargs)

  assert_exit_code 0
  assert_equals "3" "$_output"
}

function tear_down() {
  rm -rf $PARENT_DIR
}
