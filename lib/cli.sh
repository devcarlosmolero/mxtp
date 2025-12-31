#!/usr/bin/env bash

source "$MXTP_ROOT_DIR/lib/consts.sh"

function print_help() {
  echo
  echo "Usage:"
  echo "  mxtp <command> [options]"
  echo
  echo "Commands:"
  echo "  duration     Show the total playback duration of a mixtape"
  echo "  prepare      Run the main mixtape processing pipeline"
  echo "  help         Show general help or help for a specific command"
  echo
  echo "Examples:"
  echo "  mxtp duration"
  echo "  mxtp prepare -c trim,normalize -l 46"
  echo "  mxtp help prepare"
  echo
}

function print_prepare_help() {
  echo
  echo "Usage:"
  echo "  mxtp prepare [options]"
  echo
  echo "Options:"
  echo "  -c <list>    Comma-separated list of commands to run"
  echo "               Example: -c trim,normalize"
  echo
  echo "  -f <args>    ffmpeg loudnorm parameters (I, TP, LRA)"
  echo "               Only applied when running the 'normalize' command"
  echo "               Example: -f \"-14 -6 10\""
  echo
  echo "  -l <length> Cassette length in minutes"
  echo "               Allowed values: 46, 60, 90"
  echo "               Example: -l 46"
  echo
  echo "  -m <path>   Move output files to another directory or volume"
  echo "               Example: -m \"\$HOME/example\""
  echo
}

function validate_prepare_flags() {
  local -n _commands_opts=$1
  local _cassette_length_opts=$2
  local _ffmpeg_opts=$3
  local _move_opts=$4

  local _valid_commands=("$CMD_TRIM" "$CMD_NORMALIZE" "$CMD_REORGANIZE")
  local _is_valid=false
  local _requires_cassette_length=false

  for cmd in "${_commands_opts[@]}"; do
    _is_valid=false
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
      log_fatal "Cassette length is required when 'reorganize' command is used."
    fi

    case "$_cassette_length_opts" in
    46 | 60 | 90) ;;
    *)
      log_fatal "Invalid cassette length '$_cassette_length_opts'. Must be 46, 60, or 90."
      ;;
    esac
  fi
}
