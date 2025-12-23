#!/usr/bin/env bash

source "$MXTP_ROOT_DIR/lib/pb.sh"
source "$MXTP_ROOT_DIR/lib/filesystem.sh"
source "$MXTP_ROOT_DIR/lib/format.sh"

ROOT_DIR="$MXTP_USER_ROOT_DIR/$1"
EXT=$2
CASSETTE_MINUTES=$3

SIDE_SECONDS=$(((CASSETTE_MINUTES * 60) / 2))
MARGIN=120 # 2 minutes

pb_init 100 30

declare -a files
declare -a durations

total_seconds=0
cassette_total_seconds=$((CASSETTE_MINUTES * 60))

while IFS= read -r -d '' file; do
    files+=("$file")
    dur=$(ffprobe -v error -show_entries format=duration \
        -of default=noprint_wrappers=1:nokey=1 "$file" 2>/dev/null)
    dur=${dur:-0}
    durations+=("$dur")
    total_seconds=$(echo "$total_seconds + $dur" | bc)
done < <(get_files_ext "$ROOT_DIR/mxtp" "$EXT")

if (($(echo "$total_seconds + 2*$MARGIN > $cassette_total_seconds" | bc -l))); then
    log_fatal "Total duration ($(from_seconds_to_duration "$total_seconds")) exceeds cassette limit of $CASSETTE_MINUTES min"
fi

side1=()
side2=()
side1_duration=$MARGIN
side2_duration=$MARGIN

for i in "${!files[@]}"; do
    file="${files[$i]}"
    dur=${durations[$i]}
    dur=${dur:-0}

    if (($(echo "$side1_duration <= $side2_duration" | bc -l))); then
        side1+=("$file")
        side1_duration=$(echo "$side1_duration + $dur" | bc)
    else
        side2+=("$file")
        side2_duration=$(echo "$side2_duration + $dur" | bc)
    fi
done

function create_silence() {
    local _seconds=$1
    local _output_file=$2

    ffmpeg -f lavfi \
        -i anullsrc=r=44100:cl=mono \
        -t "$_seconds" \
        -b:a 32k \
        -acodec libmp3lame "$_output_file" 2>/dev/null
}

function process_side() {
    local -n _side_files=$1
    local _side_duration=$2
    local _label=$3

    local _used_duration=$(echo "$_side_duration - $MARGIN" | bc)
    local _pct=$(printf "%.0f" "$(echo "$_used_duration / $SIDE_SECONDS * 100" | bc -l)")

    pb_update "$_pct" "$_label"
    echo

    local _count=1

    for f in "${_side_files[@]}"; do
        ext="${f##*.}"
        if [[ "$_label" == "Side 1" ]]; then
            new_name=$(printf "A%02d_%s.%s" "$_count" "$(basename "$f" ."$ext")" "$ext")
        else
            new_name=$(printf "B%02d_%s.%s" "$_count" "$(basename "$f" ."$ext")" "$ext")
        fi
        cp "$f" "$ROOT_DIR/mxtp/$new_name"
        rm "$f"
        ((_count++))
    done

    if [[ "$_label" == "Side 1" ]]; then
        silence_name=$(printf "A%02d_Silence.mp3" "$_count")
    else
        silence_name=$(printf "B%02d_Silence.mp3" "$_count")
    fi

    create_silence "$((CASSETTE_MINUTES * 60 / 2))" "$ROOT_DIR/mxtp/$silence_name"
}

process_side side1 "$side1_duration" "Side 1"
process_side side2 "$side2_duration" "Side 2"

total_usage=$(echo "(($side1_duration + $side2_duration - 2*$MARGIN)/(2*$SIDE_SECONDS))*100" | bc -l | awk '{printf "%.1f", $0}')

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

printf "%b" "$table_content" | gum table --separator "|" --border double --cell.padding "0 1" --print

echo
echo "✔ Reorganization complete!"
