#!/usr/bin/env bash

source "$MXTP_ROOT_DIR/lib/startup.sh"
source "$MXTP_ROOT_DIR/lib/gum.sh"
source "$MXTP_ROOT_DIR/lib/logger.sh"
source "$MXTP_ROOT_DIR/lib/utils.sh"

CMD_DURATION="DURATION"
CMD_TRIM="TRIM"
CMD_NORMALIZE="NORMALIZE"
CMD_REORGANIZE="REORGANIZE"

CMD=$1

CASSETTE_LENGTH_46=46
CASSETTE_LENGTH_60=60
CASSETTE_LENGTH_90=90

length=

function show_lengths() {
    local choices

    choices=$(gum choose "$CASSETTE_LENGTH_46" "$CASSETTE_LENGTH_60" "$CASSETTE_LENGTH_90" --header "Select the length of your cassette")
    echo "$choices"
}

function execute() {
    case $1 in
    "$CMD_DURATION")
        source "$MXTP_ROOT_DIR/commands/duration.sh" $2 "mp3" $3
        ;;
    "$CMD_TRIM")
        source "$MXTP_ROOT_DIR/commands/trim.sh" $2 "mp3" $3
        ;;
    "$CMD_NORMALIZE")
        source "$MXTP_ROOT_DIR/commands/normalize.sh" $2 "mp3" $3
        ;;
    "$CMD_REORGANIZE")
        source "$MXTP_ROOT_DIR/commands/reorganize.sh" $2 "mp3" $3
        ;;
    esac
}

printf '%b\n' \
    "\e[38;5;240m   ____________________________
 /|............................|
| |:\e[38;5;250m           MXTP           \e[38;5;240m:|  \033[0mGive music value again by recording and owning
| |:\e[38;5;250m     Mixtape CLI Tools    \e[38;5;240m:|  \033[0myour own cassette collection.
| |:\e[38;5;250m     ,-.   _____   ,-.    \e[38;5;240m:|   
| |:\e[38;5;33m    ( \`)) \e[38;5;250m[_____] \e[38;5;33m( \`))   \e[38;5;240m:| 
|v|:\e[38;5;33m     \`-\`   \e[38;5;250m' ' '   \e[38;5;33m\`-\`    \e[38;5;240m:|
|||:\e[38;5;51m     ,______________.     \e[38;5;240m:|
|||.....\e[38;5;51m/::::o::::::o::::\\\.....|  \e[38;5;250mProudly coded by Carlos Molero.
|^|....\e[38;5;51m/:::O::::::::::O:::\\\....|  \e[38;5;250mLinkedIn: /in/carlosmolero • Fediverse: @iscarlosmolero
|/\`---/--------------------\`---|
\`.___/ /====/ /=//=/ /====/____/
     \`--------------------'\e[0m"

check_dependency "bash"
check_dependency "ffmpeg"
check_dependency "auto-editor"

if [[ -z "$MXTP_USER_ROOT_DIR" ]]; then
    log_fatal "MXTP_USER_ROOT_DIR must be set to the parent folder containing your mixtape subfolders (add to ~/.bashrc or ~/.zshrc)."
fi

if [[ ! -d "$MXTP_USER_ROOT_DIR" ]]; then
    log_fatal "MXTP_USER_ROOT_DIR ('$MXTP_USER_ROOT_DIR') does not exist or is not a directory."
fi

if [[ $CMD == "duration" ]]; then
    directory=$(select_mixtape_directory)

    if [ -z "$directory" ]; then
        log_fatal "No directory selected"
    fi

    execute $CMD_DURATION "$directory"
fi

if [[ $CMD == "prepare" ]]; then

    length=$(show_lengths | sed '/^$/d')

    if [[ -z "$length" ]]; then
        log_fatal "No length selected"
        exit 1
    fi

    directory=$(select_mixtape_directory)

    if [ -z "$directory" ]; then
        log_fatal "No directory selected"
    fi

    if [ ! -d "$MXTP_USER_ROOT_DIR/$directory/mxtp" ]; then
        mkdir -p "$MXTP_USER_ROOT_DIR/$directory/mxtp"
    else
        rm -rf "$MXTP_USER_ROOT_DIR/$directory/mxtp"
        mkdir -p "$MXTP_USER_ROOT_DIR/$directory/mxtp"
    fi

    gum confirm && {
        execute "$CMD_TRIM" "$directory"
        execute "$CMD_NORMALIZE" "$directory"
        execute "$CMD_REORGANIZE" "$directory" "$length"
    } || exit 0
fi

if [[ "$CMD" != "prepare" && "$CMD" != "duration" ]]; then
    echo
    echo "Usage: mxtp [cmd]"
    echo
    echo "Commands:"
    echo "  duration            Show the total playback duration of your mixtape"
    echo "  prepare             Open an interactive menu to choose commands to run"
    echo
    exit 0
fi
