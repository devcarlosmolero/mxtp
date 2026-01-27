#!/usr/bin/env bash

PB_TOTAL=0
PB_WIDTH=50

__PB_START_TIME=0

function pb_init() {
  PB_TOTAL=$1
  PB_WIDTH=${2:-50}
  __PB_START_TIME=$(date +%s)
  printf "\n"
}

function pb_update() {
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
