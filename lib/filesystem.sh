#!/usr/bin/env bash

source "$MXTP_ROOT_DIR/lib/logger.sh"

function get_count_files_ext() {
  find "$1" -maxdepth 1 -type f -iname "*.$2" | wc -l
}

function get_files_ext() {
  find "$1" -maxdepth 1 -type f -iname "*.$2" -print0
}
