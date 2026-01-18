#!/usr/bin/env bash

function test_e2e_help() {
  local _output

  _output=$(bash $MXTP_ROOT_DIR/mxtp.sh help 2>&1)

  assert_exit_code 0
  assert_contains "Usage" "$_output"
}

function test_e2e_help_prepare() {
  local _output

  _output=$(bash $MXTP_ROOT_DIR/mxtp.sh help prepare 2>&1)

  assert_exit_code 0
  assert_contains "Options" "$_output"
}

function test_e2e_duration() {
  local _output

  _output=$(bash $MXTP_ROOT_DIR/mxtp.sh duration "$HOME" 2>&1)

  assert_exit_code 0
}
