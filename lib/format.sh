#!/usr/bin/env bash

function from_seconds_to_duration() {
    local total_sec=$(printf "%.0f" "$1")
    local hours=$((total_sec / 3600))
    local minutes=$(((total_sec % 3600) / 60))
    local seconds=$((total_sec % 60))

    if ((hours > 0)); then
        printf "%dh %dm %ds" "$hours" "$minutes" "$seconds"
    elif ((minutes > 0)); then
        printf "%dm %ds" "$minutes" "$seconds"
    else
        printf "%ds" "$seconds"
    fi
}

function truncate() {
    local s="$1"
    local max=40
    if ((${#s} > max)); then
        echo "${s:0:$((max-1))}…"
    else
        echo "$s"
    fi
}
