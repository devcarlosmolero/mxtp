#!/usr/bin/env bash

PARENT_DIR="$(pwd)/filesystem-test"
EXISTING_CHILD_DIR_NAME="exist"

function set_up_before_script() {
  source "$MXTP_ROOT_DIR/lib/filesystem.sh"

  mkdir -p "$PARENT_DIR"
  mkdir -p "$PARENT_DIR/$EXISTING_CHILD_DIR_NAME"
}

function test_filesystem_get_command_input_dir_returns_parent_dir_if_child_dir_does_not_exist() {
  local _output

  _output=$( (get_command_input_dir "$PARENT_DIR" "does_not_exist") 2>&1)

  assert_equals "$_output" "$PARENT_DIR"
}

function test_filesystem_get_command_input_dir_returns_child_dir_if_it_exists() {
  local _output

  _output=$( (get_command_input_dir "$PARENT_DIR" "$EXISTING_CHILD_DIR_NAME") 2>&1)

  assert_equals "$_output" "$PARENT_DIR/$EXISTING_CHILD_DIR_NAME"
}

function tear_down_after_script() {
  rm -rf "$PARENT_DIR"
}
