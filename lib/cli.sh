#!/usr/bin/env bash

source "$MXTP_ROOT_DIR/lib/consts.sh"
source "$MXTP_ROOT_DIR/lib/logger.sh"

function print_about() {
  gum style \
    --border rounded \
    --border-foreground "#5F00FF" \
    --padding "1 3" \
    --width 62 \
    --align left \
    "$(gum style --bold --foreground "#FFAF00" "Give music value again")
by recording and owning your own cassette collection.

$(gum style --faint "Proudly coded by Carlos Molero")

$(gum style --foreground "#00AFFF" "LinkedIn:") /in/iscarlosmolero
$(gum style --foreground "#00AFFF" "Fediverse:") @iscarlosmolero"
}

function print_help() {
  echo
  echo "Usage:"
  echo "  mxtp <command> [options]"
  echo
  echo "Commands:"
  echo "  prepare      Run the main mixtape processing pipeline"
  echo "  help         Show general help, use -h to show help for the prepare command"
  echo "  about        Show information about the author"
  echo
  echo "Examples:"
  echo "  mxtp prepare -i /path/to/dir -c duration,normalize -f \""loudnorm=I=-12:TP=-1:LRA=8"\""
  echo "  mxtp prepare -i /path/to/dir -c duration,trim,normalize,reorganize -l 46 -m /path/to/external/volume"
  echo
}

function print_prepare_help() {
  echo
  echo "Usage:"
  echo "  mxtp prepare [options]"
  echo
  echo "Options:"
  echo "  -i <path> (*)    Set the music files directory"
  echo "                   Example: -i /path/to/dir"
  echo
  echo "  -c <list> (*)    Comma-separated list of commands to run"
  echo "                   Available commands: duration,trim,normalize,reorganize"
  echo "                   Example: -c trim,normalize"
  echo
  echo "  -f <args>        ffmpeg loudnorm parameters (I, TP, LRA)"
  echo "                   Only applied when running the '$CMD_NORMALIZE' command"
  echo "                   Example: -f \""loudnorm=I=-12:TP=-1:LRA=8"\""
  echo
  echo "  -l <length>      Cassette length in minutes"
  echo "                   Required when running the '$CMD_REORGANIZE' command"
  echo "                   Allowed values: 46, 60, 90"
  echo "                   Example: -l 46"
  echo
  echo "  -m <path>        Move output files to another directory or volume"
  echo "                   Example: -m /path/to/dir"
  echo
  echo "  -h               Show help"
  echo
}

function print_failed_files() {
  local _fail_count="$1"
  local _total="$2"
  shift 2

  if ((_fail_count == 0)); then
    return 0
  fi

  echo
  echo "Failed files:"
  for file in "$@"; do
    echo -e "$RED  • $file $RESET"
  done
}

function validate_prepare_flags() {
  local _input_opts=$1
  local -n _commands_opts=$2
  local _cassette_length_opts=$3
  local _ffmpeg_opts=$4
  local _move_opts=$5

  local _requires_cassette_length=false

  if [[ -z "$_input_opts" ]]; then
    log_fatal "Input (-i) flag is required."
  fi

  if [[ -n "$_input_opts" && ! -d "$_input_opts" ]]; then
    log_fatal "Input directory '$_input_opts' does not exist or is not a directory."
  fi

  for cmd in "${_commands_opts[@]}"; do
    local _is_valid=false
    local _valid_commands=("$CMD_DURATION" "$CMD_TRIM" "$CMD_NORMALIZE" "$CMD_REORGANIZE")

    for valid_cmd in "${_valid_commands[@]}"; do
      if [[ "$cmd" == "$valid_cmd" ]]; then
        _is_valid=true

        if [[ "$cmd" == "$CMD_REORGANIZE" ]]; then
          _requires_cassette_length=true
        fi

        break
      fi
    done

    if [[ "$_is_valid" != true ]]; then
      log_fatal "Unrecognized command '$cmd'"
    fi
  done

  if [[ "$_requires_cassette_length" == true ]]; then
    if [[ -z "$_cassette_length_opts" ]]; then
      log_fatal "Cassette length (-l) is required when 'reorganize' command is used."
    fi

    local _is_valid=false
    for length in "${CASSETTE_LENGTHS[@]}"; do
      if [[ "$_cassette_length_opts" == "$length" ]]; then
        _is_valid=true
        break
      fi
    done

    if [[ "$_is_valid" != true ]]; then
      log_fatal "Invalid cassette length '$_cassette_length_opts'. Must be 46, 60, or 90."
    fi
  fi

  if [[ -n "$_move_opts" && ! -d "$_move_opts" ]]; then
    log_fatal "Move directory '$_move_opts' does not exist or is not a directory."
  fi
}
