# screencast.sh

Record part of your screen in WEBM`*` and (optionally) upload it.

## Requirements
 - `ffmpeg` (video recording)
 - `key-mon` (for keyboard demonstration)
 - `zenity` (*optional*, upload prompts)
 
## Configuration

Here are default values:

- Target file location (by default all videos are saved in your `$HOME` directory)

	```
	targetbase=$HOME
	```
- Date format

	```
	now=$(date +"%Y_%m_%d_%H_%M_%S")
	```
- Upload server

	```
	uploadserver="host/sharing/"
	```
- Temporary AVI file location

	```
	f1="${targetbase}/screencast_temp.avi"
	```
- Final WEBM file location

	```
	f2="${targetbase}/screencast_${now}.webm"
	```
- Temporary PID file location

	```
	screencast_pid="${targetbase}/screencast.pid"
	```

## Usage

1. Run once to start recording
2. Run again to stop

I find it handy just to bind it to a key.

---

`*` is is being recorded in lossless `AVI` and then converted to `WEBM`
