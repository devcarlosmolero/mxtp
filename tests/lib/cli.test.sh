#!/usr/bin/env bash

function set_up() {
  source "$MXTP_ROOT_DIR/lib/consts.sh"
  source "$MXTP_ROOT_DIR/lib/cli.sh"
}

function test_cli_validate_prepare_flags_fail_if_missing_input_dir() {
  local _output
  local _exit_code
  local _commands=($CMD_TRIM)

  _output=$( (validate_prepare_flags "" _commands "" "" "") 2>&1)

  assert_exit_code 1
}

function test_cli_validate_prepare_flags_fail_if_invalid_input_dir() {
  local _output
  local _exit_code
  local _commands=($CMD_TRIM)

  _output=$( (validate_prepare_flags "invalid" _commands "" "" "") 2>&1)

  assert_exit_code 1
}

function test_cli_validate_prepare_flags_fail_if_unrecognized_command() {
  local _output
  local _exit_code
  local _commands=($CMD_TRIM "invalid")

  _output=$( (validate_prepare_flags "$HOME" _commands "" "" "") 2>&1)

  assert_exit_code 1
}

function test_cli_validate_prepare_flags_fail_if_reorganize_without_length() {
  local _output
  local _exit_code
  local _commands=($CMD_REORGANIZE)

  _output=$( (validate_prepare_flags "$HOME" _commands "" "" "") 2>&1)

  assert_exit_code 1
}

function test_cli_validate_prepare_flags_fail_if_reorganize_invalid_length() {
  local _output
  local _exit_code
  local _commands=($CMD_REORGANIZE)

  _output=$( (validate_prepare_flags "$HOME" _commands 22 "" "" "") 2>&1)

  assert_exit_code 1
}

function test_cli_validate_prepare_flags_fail_if_invalid_move_dir() {
  local _output
  local _exit_code
  local _commands=($CMD_TRIM)

  _output=$( (validate_prepare_flags "$HOME" _commands "" "" "invalid") 2>&1)

  assert_exit_code 1
}

function test_cli_validate_prepare_flags_happy_path() {
  local _output
  local _exit_code
  local _commands=($CMD_TRIM)

  _output=$( (validate_prepare_flags "$HOME" _commands "" "" "") 2>&1)

  assert_exit_code 0
}
