#!/bin/bash

source lib/logger.sh

function check_dependency() {
    case $1 in
    "bash") 
        local bash_version=${BASH_VERSION:0:1}
        if [[ $bash_version -lt 5 ]]; then logerr "Bash version must be at least 5"; fi
    ;;
    esac
}
