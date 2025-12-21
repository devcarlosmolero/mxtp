#!/bin/bash

source lib/filesystem.sh
source lib/consts.sh

function select_directory(){
    directory=$(get_subdirectories "$MXTP_ROOT_DIR" | gum filter)

    if [[ -z "$directory" ]]; then
        log_fatal "No directory selected"
        exit 0
    fi

    echo "$directory"
}

function print_failed_files(){
    if [[ $1 -gt 0 ]]; then
        gum confirm "$1 of $2 file(s) could not be normalized. Would you like to see the list?" && {
            for file in $3; do
                echo "Failed files:"
                echo -e "$RED  • $file $RESET"
            done
        } || return 0
    else
        return 0
    fi
}