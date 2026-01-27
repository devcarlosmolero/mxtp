PARENT_DIR="$(pwd)/e2e-test"
MOVE_DIR="$PARENT_DIR/mv"

function set_up() {
  local _duration=5
  local _songs=("song1" "song2" "song3")

  mkdir -p $PARENT_DIR
  mkdir -p $MOVE_DIR

  for song in "${_songs[@]}"; do
    ffmpeg -nostdin -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 -t "$_duration" -q:a 9 -acodec libmp3lame "$PARENT_DIR/$song.mp3" >/dev/null 2>&1
  done

  source "$MXTP_ROOT_DIR/lib/consts.sh"
}

function test_e2e_help() {
  local _output

  _output=$(bash $MXTP_ROOT_DIR/mxtp.sh help)

  assert_exit_code 0
  assert_contains "Usage" "$_output"
}

function test_e2e_prepare_help_flag() {
  local _output

  _output=$(bash $MXTP_ROOT_DIR/mxtp.sh prepare -h)

  assert_exit_code 0
  assert_contains "Options" "$_output"
}

function test_e2e_prepare() {
  local _output

  _output=$(bash $MXTP_ROOT_DIR/mxtp.sh prepare -i $PARENT_DIR -c "$CMD_DURATION,$CMD_TRIM,$CMD_NORMALIZE,$CMD_REORGANIZE" -l 46 -m $MOVE_DIR)

  assert_exit_code 0
  assert_directory_exists "$PARENT_DIR/$CHILD_DIR_NAME"

  _output=$(find $MOVE_DIR -maxdepth 1 -type f | wc -l | xargs)

  assert_exit_code 0
  assert_equals "2" "$_output"
}

function tear_down() {
  rm -rf $PARENT_DIR
}
