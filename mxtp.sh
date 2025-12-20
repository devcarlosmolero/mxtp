#!/bin/bash

source lib/startup.sh
source lib/filesystem.sh
source lib/logger.sh
source lib/utils.sh

CMD_DURATION="DURATION"
CMD_SHUFFLE="SHUFFLE"
CMD_TRIM="TRIM"
CMD_NORMALIZE="NORMALIZE"
CMD_PREVIEW="PREVIEW"

CMD=$1

function show_cmds() {
    local choices

    choices=$(gum choose "$CMD_DURATION" "$CMD_SHUFFLE" "$CMD_TRIM" "$CMD_NORMALIZE"  "$CMD_PREVIEW" --no-limit --header "Run one or multiple commands")
    echo "$choices"
}

function execute() {
    case $1 in
    "$CMD_DURATION")
        source commands/duration.sh $2
        ;;
    "$CMD_SHUFFLE")
        source commands/shuffle.sh $2
        ;;
    "$CMD_TRIM")
        source commands/trim.sh $2
        ;;
    "$CMD_NORMALIZE")
        source commands/normalize.sh $2
        ;;
    "$CMD_PREVIEW")
        source commands/preview.sh $2
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

if [[ $CMD == "tutorial" ]]; then
    gum pager <mxtp.txt
fi

if [[ $CMD == "menu" ]]; then
    
    if [[ $2 == "--help" ]]; then 
        echo
        echo "Usage: mxtp menu [flags]"
        echo
        echo "Flags:"
        echo "  --replace            Replace the original files"
        echo
        exit 1
    fi

    cmds=$(show_cmds)

    if [[ -z "$cmds" ]]; then
        log_fatal "No commands selected"
        exit 1
    fi

    directory=$(get_subdirectories "$MXTP_ROOT_DIR" | gum filter)

    if [[ -z "$directory" ]]; then
        log_fatal "No directory selected"
        exit 1
    fi

    gum confirm && {
        for cmd in $cmds; do
            execute "$cmd" "$directory"
        done
    } || {
        exit 1
    }

fi

if [[ "$CMD" != "tutorial" && "$CMD" != "menu" ]]; then
    echo
    echo "Usage: mxtp menu [flags]"
    echo
    echo "Commands:"
    echo "  tutorial            Show the tutorial and instructions"
    echo "  menu                Choose the commands you want to run"
    echo
    exit 1
fi
