#!/bin/bash

# === Description ===
# This script will record part of your screen
# And then prompt you to upload it

# === Installation ===
# Requirements:
#  - ffmpeg (video recording)
#  - key-mon (optional, for keyboard demonstration)
#  - zenity (optional, prompts)
#  - notify-send (optional, for friendly prompts)
#  - curl (optional, used for file upload)

# === Configuration ===
# Target file location
targetbase=$HOME
# Date format
now=$(date +"%Y_%m_%d_%H_%M_%S")
# Upload server
uploadserver="host/sharing/"
# Temporary AVI file location
f1="${targetbase}/screencast_temp.avi"
# Final WEBM file location
f2="${targetbase}/screencast_${now}.webm"
# Temporary PID file location
screencast_pid="${targetbase}/screencast.pid"

# === Usage ===
# Run to start recording (you will see an outline)
# Run to stop recording

function screencast-notify {
    echo "${1}"
	if command -v notify-send >/dev/null 2>&1; then
		notify-send "${1}"
	fi 
}

function screencast-start {
    screencast-notify "Recording now"

	if command -v key-mon >/dev/null 2>&1; then
		nohup key-mon --scale=0.7 --theme=oblivion &
	fi

	nohup ffmpeg -f x11grab -show_region 1 -r 25 -s 1024x768 -i :0.0+0,16 -vcodec huffyuv $f1 &
	# nohup ffmpeg -f x11grab -follow_mouse 150 -show_region 1 -r 25 -s 800x600 -i :0.0+0,16 -vcodec huffyuv $f1 &
	ffmpeg_pid=$!
	touch "${screencast_pid}"
	echo "${ffmpeg_pid}" > "${screencast_pid}"
}

function screencast-stop {
    pid=$(cat "${screencast_pid}")
	screencast-notify "Stopped recording"
	# Sending SIGTERM to ffmpeg PID
	kill -15 $pid
    rm "${screencast_pid}"
    rm nohup.out

    # Stopping key-mon
	if command -v key-mon >/dev/null 2>&1; then
	    killall key-mon
	fi

	# Converting AVI to WEBM
	if command -v zenity >/dev/null 2>&1; then
		ffmpeg -threads 4 -i $f1 -c:v libvpx -crf 5 -b:v 2M -c:a libvorbis -q:a 10 $f2 | zenity --progress --auto-close --pulsate
	else
		screencast-notify "Converting AVI to WEBM"
		ffmpeg -threads 4 -i $f1 -c:v libvpx -crf 5 -b:v 2M -c:a libvorbis -q:a 10 $f2
		screencast-notify "Conversion complete"
	fi
	rm $f1

	command -v zenity >/dev/null 2>&1 || { echo >&2 "For file uploading confirmation please install 'zenity'. Aborting."; exit 1; }
	screencast-rename
	screencast-upload
}

function screencast-rename {
    # Rename prompt
    if zenity --entry --text="Rename/Move video?" --entry-text=$f2 then
    	f2_old=$f2
    	f2=$?
		mv $f2_old $f2
		screencast-notify "Video was renamed to ${f2}"
  	fi
}

function screencast-upload {
    # Upload prompt
	if zenity --question --text="Upload this screencast to ${uploadserver}?"; then
		screencast-notify "Uploading now..."
		response=$(curl -F "file=@${f2}" $uploadserver)
		echo $response | xclip -sel clip
		screencast-notify "Upload complete. URL is: ${response} (copied to clipboard)"
		if zenity --question --text="Remove file?"; then
			rm "${f2}"
			screencast-notify "File has been deleted."
		fi
	fi
}

# If PID file exists, stop recording
if [ -f "${screencast_pid}" ]; then
	screencast-stop
	exit
fi

# Start recording
screencast-start
