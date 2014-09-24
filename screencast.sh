#!/bin/bash

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.


# === Description ===
# This script will record part of your screen
# And then prompt you to upload it

# === Installation ===
# Requirements:
#  - ffmpeg (video recording)
#  - key-mon (for keyboard demonstration)
#  - zenity (optional, prompts)

# === Configuration ===
# Target file location
targetbase="/home/user"
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




# If PID file exists, stop recording
if [ -f "${screencast_pid}" ]; then

    # Stopping recording
    pid=$(cat "${screencast_pid}")
	echo "Sending SIGTERM to ffmpeg process ${pid}"
	kill -15 $pid
    rm "${screencast_pid}"
    rm nohup.out

    # Stopping key-mon
    killall key-mon

	# Converting AVI to WEBM
	ffmpeg -threads 4 -i $f1 -c:v libvpx -crf 5 -b:v 2M -c:a libvorbis -q:a 10 $f2
	rm $f1

	command -v zenity >/dev/null 2>&1 || { echo >&2 "For file uploading confirmation please install 'zenity'. Aborting."; exit 1; }

	# Rename prompt
	f2_old=$f2
	f2=$(zenity --entry --text="Rename/Move video?" --entry-text=$f2)
	mv $f2_old $f2

	# Upload prompt
	if zenity --question --text="Upload this screencast to ${uploadserver}?"; then
		response=$(curl -F "file=@${f2}" $uploadserver)
		echo $response | xclip -sel clip
		echo "URL is: ${response} (copied to clipboard)"
	fi

    exit
fi

# Start recording
nohup key-mon --scale=0.7 --theme=oblivion &
nohup ffmpeg -f x11grab -show_region 1 -r 25 -s 1024x768 -i :0.0+0,16 -vcodec huffyuv $f1 &
ffmpeg_pid=$!
touch "${screencast_pid}"
echo "${ffmpeg_pid}" > "${screencast_pid}"
