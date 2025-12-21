#!/usr/bin/env bash

source "$MXTP_ROOT_DIR/lib/logger.sh"

function check_dependency() {
    case $1 in
    "bash")
        if [[ -z "$BASH_VERSION" ]]; then log_fatal "Not running under Bash"; fi
        local major_version=${BASH_VERSION%%.*}
        if ((major_version < 5)); then
            log_fatal "Bash version must be at least 5 (found $BASH_VERSION)"
        fi
        ;;
    "ffmpeg")
        command -v ffmpeg >/dev/null 2>&1 || { log_fatal "ffmpeg is required but not installed."; }
        ;;
    "auto-editor")
        command -v auto-editor >/dev/null 2>&1 || { log_fatal "auto-editor is required but not installed."; }
        ;;
    esac
}
