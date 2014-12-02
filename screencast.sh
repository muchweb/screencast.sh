#!/bin/bash

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# ================ Description ================
# This script will record part of your screen
# And then prompt you to upload it

# ================ Installation ================
# Requirements:
#  - FFmpeg (video recording)
#  - key-mon (optional, for keyboard demonstration)
#  - zenity (optional, prompts)
#  - notify-send (optional, for friendly prompts)
#  - cURL (optional, used for file upload)
#  - GNU Bash, GNU Date

# ================ Configuration ================
# Target file location
screencast_base=$HOME
# Date format
screencast_date=$(date +"%Y_%m_%d_%H_%M_%S")
# Upload server
screencast_uploadserver="http://strace.club/"
# Temporary AVI file location
screencast_avi="${screencast_base}/screencast_temp.avi"
# Final WEBM file location
screencast_webm="${screencast_base}/screencast_${screencast_date}.webm"
# Temporary PID file location
screencast_pid="${screencast_base}/screencast.pid"

# ================ Usage ================
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
		# nohup key-mon --scale=0.7 --theme=oblivion &
		nohup key-mon --scale=1 --theme=oblivion &
	fi

	nohup ffmpeg -f x11grab -follow_mouse 150 -show_region 1 -r 25 -s 1024x768 -i :0.0+0,16 -vcodec huffyuv $screencast_avi &
	# nohup ffmpeg -f x11grab -show_region 1 -r 25 -s 1024x768 -i :0.0+0,16 -vcodec huffyuv $screencast_avi &
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
		ffmpeg -threads 4 -i $screencast_avi -c:v libvpx -crf 5 -b:v 2M -c:a libvorbis -q:a 10 $screencast_webm | zenity --progress --auto-close --pulsate
	else
		screencast-notify "Converting AVI to WEBM"
		ffmpeg -threads 4 -i $screencast_avi -c:v libvpx -crf 5 -b:v 2M -c:a libvorbis -q:a 10 $screencast_webm
		screencast-notify "Conversion complete"
	fi
	rm $screencast_avi

	command -v zenity >/dev/null 2>&1 || { echo >&2 "For file uploading confirmation please install 'zenity'. Aborting."; exit 1; }
	screencast-rename
	screencast-upload
}

function screencast-rename {
	# Rename prompt
	ENTRY=$(zenity --entry --text="Rename/Move video?" --entry-text=$screencast_webm)
	if [ $? == 0 ]
	then
		screencast_webm_old=$screencast_webm
		screencast_webm=$ENTRY
		mv $screencast_webm_old $screencast_webm
		screencast-notify "Video was renamed to ${screencast_webm}"
	fi
}

function screencast-upload {
	# Upload prompt
	if zenity --question --text="Upload this screencast to ${screencast_uploadserver}?"; then
		screencast-notify "Uploading now..."
		response=$(curl -F "file[]=@${screencast_webm}" $screencast_uploadserver)
		echo $response | xclip -sel clip
		screencast-notify "Upload complete. URL is: ${response} (copied to clipboard)"
		if zenity --question --text="Remove file (${screencast_webm})?"; then
			rm $screencast_webm
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
