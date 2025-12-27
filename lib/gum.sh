#!/usr/bin/env bash

source "$MXTP_ROOT_DIR/lib/filesystem.sh"
source "$MXTP_ROOT_DIR/lib/consts.sh"

function select_user_root_subdirectory() {
    local _directory=$(get_user_root_subdirectories "$MXTP_USER_ROOT_DIR" | gum filter)

    if [[ -z "$_directory" ]]; then
        log_fatal "No directory selected"
        exit 0
    fi

    echo "$_directory"
}

function select_external_volume() {
    local _volume=$(get_external_volumes | gum filter)

    if [[ -z "$_volume" ]]; then
        log_fatal "No volume selected"
        exit 0
    fi

    echo "$_volume"
}

function print_failed_files() {
    local _fail_count="$1"
    local _total="$2"
    shift 2

    if ((_fail_count == 0)); then
        return 0
    fi

    gum confirm "$_fail_count of $_total file(s) could not be normalized. Would you like to see the list?" || return 0

    echo
    echo "Failed files:"
    for file in "$@"; do
        echo -e "$RED  • $file $RESET"
    done
}
