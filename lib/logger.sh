#!/bin/bash

declare -A ansi_colors

ansi_colors[red]='\033[0;31m'
ansi_colors[green]='\033[0;32m'
ansi_colors[yellow]='\033[0;33m'
ansi_colors[purple]='\033[0;35m'
ansi_colors[reset]='\033[0m'

function log_debug(){
    echo -e "${ansi_colors[purple]}DEBUG: $1${ansi_colors[reset]}"
}

function log_warn(){
    echo -e "${ansi_colors[yellow]}WARNING: $1${ansi_colors[reset]}"
}

function log_err(){
    echo -e "${ansi_colors[red]}ERROR: $1${ansi_colors[reset]}"
    exit 1
}

