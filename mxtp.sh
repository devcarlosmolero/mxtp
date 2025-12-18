#!/bin/bash

source lib/startup.sh
source lib/filesystem.sh
source lib/logger.sh


CMD_CHECK_DURATION="Check duration"
CMD_NORMALIZE="Normalize"
CMD_SHUFFLE="Shuffle"
CMD_TRIMM="Trimm"


function show_top_level_choices() {
     local choices
     
     choices=$(gum choose "$CMD_CHECK_DURATION" "$CMD_NORMALIZE" "$CMD_SHUFFLE" "$CMD_TRIMM" --no-limit)
     echo "$choices"
}

function check_dependency() {
    case $1 in
    "$CMD_CHECK_DURATION") 
        echo ""
    ;;
    "$CMD_NORMALIZE") 
        echo ""
    ;;
    "$CMD_SHUFFLE") 
        echo ""
    ;;
    "$CMD_TRIMM") 
        echo ""
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

echo ""
echo "All options are multiple. Press X or the SPACE bar to select an option."
echo ""

top_level_choices=$(show_top_level_choices)
log_debug "$top_level_choices"
# directories=$(get_subdirectories "$MXTP_ROOT_DIR" | gum choose --no-limit)
# echo $top_levbel