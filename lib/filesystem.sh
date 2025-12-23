#!/usr/bin/env bash

source "$MXTP_ROOT_DIR/lib/logger.sh"

function get_user_root_subdirectories() {
  local _directory="$1"

  if [[ -d "$_directory" ]]; then
    find "$_directory" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;
  else
    log_fatal "Parent directory '$_directory' doesn't exist"
    return 1
  fi
}

function get_count_files_ext() {
  find "$1" -maxdepth 1 -type f -iname "*.$2" | wc -l
}

function get_files_ext() {
  find "$1" -maxdepth 1 -type f -iname "*.$2" -print0
}
