#!/bin/bash

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
    local current=$1
    local label=$2

    label=${label:0:40}

    local percent=$(( current * 100 / PB_TOTAL ))
    local filled=$(( percent * PB_WIDTH / 100 ))
    local empty=$(( PB_WIDTH - filled ))

    printf "\r\033[2K\033[?25l["

    printf "%0.s█" $(seq 1 $filled)
    printf "%0.s░" $(seq 1 $empty)

    printf "] %3d%% %s" "$percent" "$label"

    printf "\033[?25h"

    if [[ $current -ge $PB_TOTAL ]]; then
        echo
    fi
}