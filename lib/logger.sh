#!/usr/bin/env bash

# Logging utility functions for MXTP.
# This file contains functions for logging messages at different levels.

# Logs a debug message.
#
# Args:
#   $1: The message to log.
log_debug() {
  gum log --structured --level debug "$1"
}

# Logs an info message.
#
# Args:
#   $1: The message to log.
log_info() {
  gum log --structured --level info "$1"
}

# Logs a warning message.
#
# Args:
#   $1: The message to log.
log_warn() {
  gum log --structured --level warn "$1"
}

# Logs an error message.
#
# Args:
#   $1: The message to log.
log_error() {
  gum log --structured --level error "$1"
}

# Logs a fatal message and exits the script.
#
# Args:
#   $1: The message to log.
log_fatal() {
  gum log --structured --level fatal "$1"
  exit 1
}
