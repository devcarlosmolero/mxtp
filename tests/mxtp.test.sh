function test_e2e_help() {
  local _output

  _output=$(bash $MXTP_ROOT_DIR/mxtp.sh help 2>&1)

  assert_exit_code 0
  assert_contains "Usage" "$_output"
}

function test_e2e_prepare_help_flag() {
  local _output

  _output=$(bash $MXTP_ROOT_DIR/mxtp.sh prepare -h 2>&1)

  assert_exit_code 0
  assert_contains "Options" "$_output"
}
