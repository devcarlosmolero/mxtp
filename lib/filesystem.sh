#!/bin/bash

source lib/logger.sh

get_subdirectories() {
  local directory="$1"

  if [[ -d "$directory" ]]; then
    find "$directory" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;
  else
    log_fatal "Parent directory '$directory' doesn't exist"
    return 1
  fi
}
