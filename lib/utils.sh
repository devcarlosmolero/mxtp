#!/bin/bash

function contains() {
    local array_name=$1
    local value=$2

    local array=("${!array_name}")

    for item in "${array[@]}"; do
        [[ "$item" == "$value" ]] && return 0
    done

    return 1
}