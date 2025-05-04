#!/bin/bash
filename='./musicCatalog/*'
clockLength='100'
videoPlayer='mpv'
while getopts "hcvkpf:t:" flag; do
  case $flag in
    h)
        echo "This program cycles through songs and notifies the user when it does"
        echo " "
        echo "flags:"
        echo "  {-h} Help"
        echo "  {-s} stops at end of the list"
        echo "  {-v} enables video playback"
        echo "  {-k} stops the clear command from being used"
        echo "  {-p} uses device video player, most players need -v flag"
        echo "  {-f [directory]} specify where to play from defaults to $filename"
        echo "  {-t [int]} takes a percent of time 1000 is 100% and 10 is 1%"
        exit 1
        ;;
    c)
        # stop at end of list
        ;;
    v)
        # enables video playback
        ;;
    k)
        # don't clear lines after each song
        ;;
    p)
        videoPlayer='xdg-open'
        # set to use default player instead of mpv
        ;;
    f)
        filename="$OPTARG/*"
        # Process the specified folder
        ;;
    t)
        clockLength="$OPTARG"
        # % of time to show notification
        ;;
    \?) # Handle invalid options
        echo "invalid flag -h for help"
        exit 1
       ;;
  esac
done
echo "checking every file in $filename"
while true; do
    for file in $filename; do
        if [ -f "$file" ]; then
            if [[ $* != *-k* ]]; then
                clear
            fi
            echo 'Now Playing:'
            echo "$(basename "${file::-4}")"
            #uses ffprobe to probe the time in decimal milliseconds
            time="$(ffprobe -v error -select_streams v:0 -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file")"
            clockTime=$(($(printf "%.0f" "$time") * $clockLength))
            echo "Notification length: $clockTime or $(($clockLength / 10))% total time"
            echo "$(basename "${file::-4}")" | while read OUTPUT; do notify-send -t "$clockTime" --hint=int:transient:1 'Now Playing' "$OUTPUT"; done
            if [[ $* == *-v* ]]; then
                $videoPlayer "$file"
            else
                $videoPlayer --no-video "$file"
            fi
        else
            echo "skipping folder: $file"
        fi
    done
    if [[ $* == *-c* ]]; then
        break
    fi
done
