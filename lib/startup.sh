#!/usr/bin/env bash

# Checks if required dependencies are installed.
# This function verifies the presence and version of essential tools.
source "$MXTP_ROOT_DIR/lib/logger.sh"

# Validates the installation and version of a dependency.
#
# Args:
#   $1: The name of the dependency to check.
function check_dependency() {
  case $1 in
  "bash")
    if [[ -z "$BASH_VERSION" ]]; then log_fatal "Not running under Bash"; fi
    local _major_version=${BASH_VERSION%%.*}

    if ((_major_version < 5)); then
      log_fatal "Bash version must be at least 5 (found $BASH_VERSION)"
    fi
    ;;
  "ffmpeg")
    command -v ffmpeg >/dev/null 2>&1 || { log_fatal "ffmpeg is required but not installed."; }
    ;;
  "auto-editor")
    command -v auto-editor >/dev/null 2>&1 || { log_fatal "auto-editor is required but not installed."; }
    ;;
  "gum")
    command -v gum >/dev/null 2>&1 || { log_fatal "gum is required but not installed."; }
    ;;
  "jq")
    command -v jq >/dev/null 2>&1 || { log_fatal "jq is required but not installed."; }
    ;;
  "bc")
    command -v bc >/dev/null 2>&1 || { log_fatal "bc is required but not installed."; }
    ;;
  "parallel")
    command -v parallel >/dev/null 2>&1 || { log_fatal "parallel is required but not installed."; }
    ;;
  esac
}
