#!/bin/bash

function log_debug() {
    gum log --structured --level debug "$1"
}

function log_info() {
    gum log --structured --level info "$1"
}

function log_warn() {
    gum log --structured --level warn "$1"
}

function log_error() {
    gum log --structured --level error "$1"
}

function log_fatal() {
    gum log --structured --level fatal "$1"
    exit 1
}
