#!/usr/bin/env bash

source "$MXTP_ROOT_DIR/lib/startup.sh"
source "$MXTP_ROOT_DIR/lib/gum.sh"
source "$MXTP_ROOT_DIR/lib/logger.sh"
source "$MXTP_ROOT_DIR/lib/cli.sh"
source "$MXTP_ROOT_DIR/lib/consts.sh"

CMD=$1

commands_opts=
cassette_length_opts=
ffmpeg_opts=
move_opts=

function execute() {
  case $1 in
  "$CMD_DURATION")
    source "$MXTP_ROOT_DIR/commands/duration.sh" $2
    ;;
  "$CMD_TRIM")
    source "$MXTP_ROOT_DIR/commands/trim.sh" $2
    ;;
  "$CMD_NORMALIZE")
    source "$MXTP_ROOT_DIR/commands/normalize.sh" $2
    ;;
  "$CMD_REORGANIZE")
    source "$MXTP_ROOT_DIR/commands/reorganize.sh" $2 $3
    ;;
  "$CMD_MOVE")
    source "$MXTP_ROOT_DIR/commands/move.sh" $2 $3
    ;;
  esac
}

printf '%b\n' \
  "\e[38;5;240m   ____________________________
 /|............................|
| |:\e[38;5;250m           MXTP           \e[38;5;240m:|  \033[0mGive music value again by recording and owning
| |:\e[38;5;250m     Mixtape CLI Tools    \e[38;5;240m:|  \033[0myour own cassette collection.
| |:\e[38;5;250m     ,-.   _____   ,-.    \e[38;5;240m:|   
| |:\e[38;5;33m    ( \`)) \e[38;5;250m[_____] \e[38;5;33m( \`))   \e[38;5;240m:| 
|v|:\e[38;5;33m     \`-\`   \e[38;5;250m' ' '   \e[38;5;33m\`-\`    \e[38;5;240m:|
|||:\e[38;5;51m     ,______________.     \e[38;5;240m:|
|||.....\e[38;5;51m/::::o::::::o::::\\\.....|  \e[38;5;250mProudly coded by Carlos Molero.
|^|....\e[38;5;51m/:::O::::::::::O:::\\\....|  \e[38;5;250mLinkedIn: /in/carlosmolero • Fediverse: @iscarlosmolero
|/\`---/--------------------\`---|
\`.___/ /====/ /=//=/ /====/____/
     \`--------------------'\e[0m"

check_dependency "bash"
check_dependency "ffmpeg"
check_dependency "auto-editor"

if [[ -z "$MXTP_USER_ROOT_DIR" ]]; then
  log_fatal "MXTP_USER_ROOT_DIR must be set to the parent folder containing your mixtape subfolders (add to ~/.bashrc or ~/.zshrc)."
fi

if [[ ! -d "$MXTP_USER_ROOT_DIR" ]]; then
  log_fatal "MXTP_USER_ROOT_DIR ('$MXTP_USER_ROOT_DIR') does not exist or is not a directory."
fi

if [[ $CMD == "help" ]]; then
  if [[ "$2" == "prepare" ]]; then
    print_prepare_help
    exit 0
  fi

  print_help
  exit 0
fi

if [[ $CMD == "duration" ]]; then
  directory=$(select_user_root_subdirectory)

  if [ -z "$directory" ]; then
    log_fatal "No directory selected"
  fi

  execute $CMD_DURATION "$directory"
fi

if [[ $CMD == "prepare" ]]; then
  shift

  while getopts "c:l:f:m" opt; do
    case "$opt" in
    c)
      IFS=',' read -r -a commands_opts <<<"$OPTARG"
      ;;
    l)
      cassette_length_opts="$OPTARG"
      ;;
    f)
      ffmpeg_opts="$OPTARG"
      ;;
    m)
      move_opts="$OPTARG"
      ;;
    esac
  done

  validate_prepare_flags commands_opts "$cassette_length_opts" "$ffmpeg_opts" "$move_opts"

  directory=$(select_user_root_subdirectory)

  if [ -z "$directory" ]; then
    log_fatal "No directory selected"
  fi

  if [ ! -d "$MXTP_USER_ROOT_DIR/$directory/mxtp" ]; then
    mkdir -p "$MXTP_USER_ROOT_DIR/$directory/mxtp"
  else
    rm -rf "$MXTP_USER_ROOT_DIR/$directory/mxtp"
    mkdir -p "$MXTP_USER_ROOT_DIR/$directory/mxtp"
  fi

  execute "$CMD_TRIM" "$directory"
  execute "$CMD_NORMALIZE" "$directory"
  execute "$CMD_REORGANIZE" "$directory" "$length"

  echo
  gum confirm "Would you like to copy the files sequentially into your volume to ensure the playback order is respected on your device?" && {
    volume=$(select_external_volume)
    execute "$CMD_MOVE" "$directory" "$volume"
  } || exit 0
fi

if [[ "$CMD" != "prepare" && "$CMD" != "duration" ]]; then
  print_help
  exit 0
fi
