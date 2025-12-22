#!/usr/bin/env bash

function contains() {
    local _array_name=$1
    local _value=$2

    local _array=("${!_array_name}")

    for item in "${_array[@]}"; do
        [[ "$item" == "$_value" ]] && return 0
    done

    return 1
}
