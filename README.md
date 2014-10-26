# screencast.sh

Record your screen in WEBM¹ and (optionally) upload it.

## Requirements
 - `ffmpeg` video recording
 - `key-mon` *optional*, for keyboard demonstration
 - `zenity` *optional*, friendly prompts
 - `notify-send` *optional*, status messages
 - `curl` *optional*, used for file upload

## Configuration

Here are default values:

- Target file location

    ```
screencast_base=$HOME
    ```

- Date format

    ```
screencast_date=$(date +"%Y_%m_%d_%H_%M_%S")
    ```

- Upload server

    ```
screencast_uploadserver="http://strace.club/"
    ```

- Temporary AVI file location

    ```
screencast_avi="${screencast_base}/screencast_temp.avi"
    ```

- Final WEBM file location

    ```
screencast_webm="${screencast_base}/screencast_${screencast_date}.webm"
    ```

- Temporary PID file location

    ```
screencast_pid="${screencast_base}/screencast.pid"
    ```

## Usage

1. Run once to start recording
2. Run again to stop

I find it handy just to bind it to a key, for example, <kbd>PrintScr</kbd>:
```
globalkeys = awful.util.table.join(
    awful.key(
       {},
       "Print",
       function()
           awful.util.spawn("bash ~/scripts/screencast.sh/screencast.sh", false)
       end
    )
)
```

---

¹: it is being recorded in lossless `AVI` and then converted to `WEBM`
