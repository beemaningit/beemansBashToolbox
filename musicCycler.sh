#!/bin/bash
filename='./musicCatalog'
clockLength='100'
videoPlayer='mpv'
while getopts "hcvkpnf:t:" flag; do
  case $flag in
    h)
        echo "This program cycles through songs and notifies the user when it does"
        echo "Unique Dependencys:"
        echo "  mpv"
        echo "  ffprobe"
        echo "  notify-send"
        echo " "
        echo "flags:"
        echo "  {-h} Help"
        echo "  {-s} stops at end of the list"
        echo "  {-v} enables video playback"
        echo "  {-k} stops the clear command from being used"
        echo "  {-p} uses device video player, most players need -v flag"
        echo "  {-n} disables notifications"
        echo "  {-f [folder]} specify where to play from defaults to $filename"
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
    n)
        # disables notifications
        ;;
    f)
        filename="$OPTARG"
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
#shows that the script did something
echo "checking every file in $filename"
while true; do
    for file in "$filename"/*; do
        if [ -f "$file" ]; then
            if [[ $* != *-k* ]]; then
                clear
            fi
            echo 'Now Playing:'
            echo "$(basename "${file::-4}")"
            #uses ffprobe to probe the time in decimal milliseconds
            time="$(ffprobe -v error -select_streams v:0 -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file")"
            #converts the time to a int and multiplies it by configurable amount
            clockTime=$(($(printf "%.0f" "$time") * $clockLength))
            if [[ $* != *-n* ]]; then
                #notifies the user when a new song starts
                echo "Notification length: $clockTime or $(($clockLength / 10))% total time"
                echo "$(basename "${file::-4}")" | while read OUTPUT; do notify-send -t "$clockTime" --hint=int:transient:1 'Now Playing' "$OUTPUT"; done
            fi
            if [[ $* == *-v* ]]; then
                $videoPlayer "$file"
            else
                #removes video so that the song gets played in the background
                $videoPlayer --no-video "$file"
            fi
        else
            #lets the user know that nested folders don't work
            echo "skipping folder: $file"
            sleep 0.1s
        fi
    done
    #stops the program when 
    if [[ $* == *-c* ]]; then
        exit 1
    fi
done
