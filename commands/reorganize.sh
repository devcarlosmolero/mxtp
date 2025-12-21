#!/usr/bin/env bash

source "$MXTP_ROOT_DIR/lib/pb.sh"
source "$MXTP_ROOT_DIR/lib/filesystem.sh"
source "$MXTP_ROOT_DIR/lib/gum.sh"
source "$MXTP_ROOT_DIR/lib/format.sh"
source "$MXTP_ROOT_DIR/lib/logger.sh"

ROOT_DIR="$MXTP_USER_ROOT_DIR/$1"
EXT=$2
CASSETTE_MIN=$3

SIDE_DURATION=$(((CASSETTE_MIN * 60) / 2))
MARGIN=120

pb_init 100 30

declare -a files
declare -a durations

while IFS= read -r -d '' file; do
    files+=("$file")
    dur=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file")
    durations+=("$dur")
done < <(get_files_ext "$ROOT_DIR" "$EXT")

total_duration=0
for dur in "${durations[@]}"; do
    total_duration=$(echo "$total_duration + $dur" | bc)
done

cassette_total=$((CASSETTE_MIN * 60))
if (($(echo "$total_duration + 2*$MARGIN > $cassette_total" | bc -l))); then
    log_fatal "Total duration ($(from_seconds_to_duration "$total_duration")) exceeds cassette limit of $CASSETTE_MIN min"
fi

side1=()
side2=()
side1_time=$MARGIN
side2_time=$MARGIN

for i in "${!files[@]}"; do
    file="${files[$i]}"
    dur=${durations[$i]}

    if (($(echo "$side1_time <= $side2_time" | bc -l))); then
        side1+=("$file")
        side1_time=$(echo "$side1_time + $dur" | bc)
    else
        side2+=("$file")
        side2_time=$(echo "$side2_time + $dur" | bc)
    fi
done

function process_side() {
    local -n _side_files=$1
    local _side_time=$2
    local _label=$3

    local real_time=$(echo "$_side_time - $MARGIN" | bc)
    local pct=$(printf "%.1f" "$(echo "$real_time/$SIDE_DURATION*100" | bc -l)")

    pb_update "$(printf "%.0f" "$pct")" "(~$(from_seconds_to_duration "$_side_time"))"

    local count=1
    for f in "${_side_files[@]}"; do
        ext="${f##*.}"
        if [[ "$_label" == "Side 1" ]]; then
            new_name=$(printf "A%02d_%s.%s" "$count" "$(basename "$f" .$ext)" "$ext")
        else
            new_name=$(printf "B%02d_%s.%s" "$count" "$(basename "$f" .$ext)" "$ext")
        fi
        cp "$f" "$ROOT_DIR/mxtp/$new_name"
    done
    echo
}

process_side side1 "$side1_time" "Side 1"
process_side side2 "$side2_time" "Side 2"

total_usage=$(echo "($side1_time + $side2_time)/(2*$SIDE_DURATION)*100" | bc -l | awk '{printf "%.1f", $0}')
echo
echo "Total cassette usage: $total_usage%"
echo

side1_names=()
for f in "${side1[@]}"; do
    side1_names+=("$(truncate "$(basename "$f")")")
done

side2_names=()
for f in "${side2[@]}"; do
    side2_names+=("$(truncate "$(basename "$f")")")
done

max_rows=${#side1_names[@]}
((${#side2_names[@]} > max_rows)) && max_rows=${#side2_names[@]}

table_content="Side A|Side B\n"

for ((i = 0; i < max_rows; i++)); do
    a="${side1_names[i]:-}"
    b="${side2_names[i]:-}"
    table_content+="$a|$b\n"
done

printf "%b" "$table_content" | gum table \
    --separator "|" \
    --border double \
    --cell.padding "0 1" \
    --print

echo
echo "✔ Reorganization complete!"
