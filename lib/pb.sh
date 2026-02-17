#!/usr/bin/env bash

# Progress bar utility functions for MXTP.
# This file contains functions for displaying and updating a progress bar.

PB_TOTAL=0
PB_WIDTH=50

__PB_START_TIME=0

# Initializes the progress bar.
#
# Args:
#   $1: The total number of items to process.
#   $2: The width of the progress bar (default: 50).
pb_init() {
  PB_TOTAL=$1
  PB_WIDTH=${2:-50}
  __PB_START_TIME=$(date +%s)
  printf "\n"
}

# Updates the progress bar.
#
# Args:
#   $1: The current number of items processed.
#   $2: The label to display next to the progress bar.
pb_update() {
  local _current=$1
  local _label=$(truncate "$2")
  local _percent=$((_current * 100 / PB_TOTAL))
  local _filled=$((_percent * PB_WIDTH / 100))
  local _empty=$((PB_WIDTH - _filled))

  printf "\r\033[2K\033[?25l["

  printf "%0.s█" $(seq 1 $_filled)
  printf "%0.s░" $(seq 1 $_empty)

  printf "] %3d%% %s" "$_percent" "$_label"

  printf "\033[?25h"

  if [[ $_current -ge $PB_TOTAL ]]; then
    echo
  fi
}
