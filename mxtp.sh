#!/usr/bin/env bash

source "$MXTP_ROOT_DIR/lib/startup.sh"
source "$MXTP_ROOT_DIR/lib/logger.sh"
source "$MXTP_ROOT_DIR/lib/cli.sh"
source "$MXTP_ROOT_DIR/lib/consts.sh"

CHOICE=$1

input_opts=
commands_opts=
cassette_length_opts=
ffmpeg_opts=
output_opts=
move_opts=

function execute() {
  case $1 in
  "$CMD_DURATION")
    bash "$MXTP_ROOT_DIR/commands/duration.sh" "$input_opts"
    ;;
  "$CMD_TRIM")
    bash "$MXTP_ROOT_DIR/commands/trim.sh" "$input_opts"
    ;;
  "$CMD_NORMALIZE")
    bash "$MXTP_ROOT_DIR/commands/normalize.sh" "$input_opts"
    ;;
  "$CMD_REORGANIZE")
    bash "$MXTP_ROOT_DIR/commands/reorganize.sh" "$input_opts" "$cassette_length_opts"
    ;;
  "$CMD_MOVE")
    bash "$MXTP_ROOT_DIR/commands/move.sh" "$input_opts"
    ;;
  esac
}

check_dependency "bash"
check_dependency "ffmpeg"
check_dependency "auto-editor"

if [[ $CHOICE == "help" ]]; then
  if [[ "$2" == "prepare" ]]; then
    print_prepare_help
    exit 0
  fi

  print_help
  exit 0
fi

if [[ $CHOICE == "prepare" ]]; then
  shift

  while getopts "i:c:l:f:o:m:" opt; do
    case "$opt" in
    i)
      input_opts="$OPTARG"
      ;;
    c)
      IFS=',' read -r -a commands_opts <<<"$OPTARG"
      ;;
    l)
      cassette_length_opts="$OPTARG"
      ;;
    f)
      ffmpeg_opts="$OPTARG"
      ;;
    o)
      output_opts="$OPTARG"
      ;;
    m)
      move_opts="$OPTARG"
      ;;
    esac
  done

  validate_prepare_flags "$input_opts" commands_opts "$cassette_length_opts" "$ffmpeg_opts" "$output_opts" "$move_opts"

  if [[ " ${commands_opts[@]} " =~ "$CMD_TRIM" || " ${commands_opts[@]} " =~ "$CMD_NORMALIZE" || " ${commands_opts[@]} " =~ "$CMD_REORGANIZE" ]]; then
    rm -rf "$input_opts/$CHILD_DIR_NAME"
  fi

  for cmd in "${commands_opts[@]}"; do
    execute "$cmd"
  done
fi

if [[ "$CHOICE" != "prepare" && "$CHOICE" != "help" ]]; then
  print_help
  exit 0
fi
