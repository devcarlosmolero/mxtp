#!/usr/bin/env bash

# Filesystem utility functions for MXTP.
# This file contains functions for interacting with the filesystem.

source "$MXTP_ROOT_DIR/lib/consts.sh"

# Determines the appropriate input directory for a command.
# If the child directory exists, it returns the child directory; otherwise, it returns the parent directory.
#
# Args:
#   $1: The parent directory.
#   $2: The child directory name.
#
# Returns:
#   The path to the appropriate input directory.
get_command_input_dir() {
  local _parent_dir=$1
  local _child_dir_name=$2

  if [[ -d "$_parent_dir/$_child_dir_name" ]]; then
    echo "$_parent_dir/$_child_dir_name"
  else
    echo "$_parent_dir"
  fi
}

# Counts the number of files with a specific extension in a directory.
#
# Args:
#   $1: The directory to search.
#   $2: The file extension.
#
# Returns:
#   The number of files with the specified extension.
get_count_files_ext() {
  find "$1" -maxdepth 1 -type f -iname "*.$2" | wc -l | xargs
}

# Lists all files with a specific extension in a directory, separated by null characters.
#
# Args:
#   $1: The directory to search.
#   $2: The file extension.
#
# Returns:
#   A null-separated list of files with the specified extension.
get_files_ext() {
  find "$1" -maxdepth 1 -type f -iname "*.$2" -print0
}
