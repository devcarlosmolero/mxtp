#!/usr/bin/env bash

source "$MXTP_ROOT_DIR/lib/consts.sh"

function get_command_input_dir() {
  local _parent_dir=$1
  local _child_dir_name=$2

  if [[ -d "$_parent_dir/$_child_dir_name" ]]; then
    echo "$_parent_dir/$_child_dir_name"
  else
    echo "$_parent_dir"
  fi
}

function get_count_files_ext() {
  find "$1" -maxdepth 1 -type f -iname "*.$2" | wc -l | xargs
}

function get_files_ext() {
  find "$1" -maxdepth 1 -type f -iname "*.$2" -print0
}
