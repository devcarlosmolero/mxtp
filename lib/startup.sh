#!/bin/bash

source lib/logger.sh

function check_dependency() {
    case $1 in
    "bash") 
        local bash_version=${BASH_VERSION:0:1}
        if [[ $bash_version -lt 5 ]]; then log_fatal "Bash version must be at least 5"; fi
    ;;
    "ffmpeg")
    command -v ffmpeg >/dev/null 2>&1 || { log_fatal "ffmpeg is required but not installed."; }
    ;;
    esac
}
