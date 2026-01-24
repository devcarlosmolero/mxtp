#!/usr/bin/env bash

function set_up() {
  source "$MXTP_ROOT_DIR/lib/format.sh"
}

function test_format_trim_leading_numbers_and_spaces() {
  local _output

  _output=$( (trim_leading_numbers_and_spaces " 02-song.mp3"))

  assert_exit_code 0
  assert_equals "$_output" "song.mp3"
}
