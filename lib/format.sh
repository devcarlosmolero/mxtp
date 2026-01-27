#!/usr/bin/env bash

function from_seconds_to_duration() {
  local _total_sec=${1%.*}
  _total_sec=${_total_sec:-0}

  local _hours=$((_total_sec / 3600))
  local _minutes=$(((_total_sec % 3600) / 60))
  local _seconds=$((_total_sec % 60))

  if ((_hours > 0)); then
    printf "%dh %dm %ds" "$_hours" "$_minutes" "$_seconds"
  elif ((_minutes > 0)); then
    printf "%dm %ds" "$_minutes" "$_seconds"
  else
    printf "%ds" "$_seconds"
  fi
}

function truncate() {
  local _s="$1"
  local _max=40

  if ((${#_s} > _max)); then
    echo "${_s:0:$((_max - 1))}…"
  else
    echo "$_s"
  fi
}

function trim_leading_numbers_and_spaces() {
  echo "$1" | sed -E 's/^[0-9 :-]+//'
}
