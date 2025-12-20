#!/bin/bash

source lib/logger.sh
source lib/consts.sh

ROOT_DIR="$MXTP_ROOT_DIR/$1"

success_count=0
fail_count=0
failed_files=()

while IFS= read -r -d '' file; do
    tmp_file="${file%.mp3}.normalized.mp3"

    ffmpeg -nostdin -y -i "$file" -af "loudnorm=I=-14:TP=-1.5:LRA=11" "$tmp_file" >/dev/null 2>&1

    if [ $? -eq 0 ] && [ -f "$tmp_file" ]; then
        mv "$tmp_file" "$file"
        log_info "$(basename "$file") was successfully normalized!"
        ((success_count++))
    else
        log_error "$(basename "$file") couldn't be normalized"
        rm -f "$tmp_file"
        ((fail_count++))
        failed_files+=("$(basename "$file")")
    fi
done < <(find "$ROOT_DIR" -type f -iname "*.mp3" -print0)

if [[ $fail_count -gt 0 ]]; then
    echo
    gum confirm "$fail_count file(s) could not be normalized. Would you like to see the list?" && {
        for file in "${failed_files[@]}"; do
            echo "Failed files:"
            echo -e "$RED  • $file $RESET"
            echo
        done
    } || exit 1
else
    exit 1
fi
