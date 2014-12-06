# screencast.sh

Record your screen in WEBM¹ and (optionally) upload it.

## Requirements
 - FFmpeg — video recording
 - `key-mon` *optional*, for keyboard demonstration
 - `zenity` *optional*, friendly prompts
 - `notify-send` *optional*, status messages
 - cURL *optional*, used for file upload
 - GNU Bash, GNU Date

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

I find it handy just to bind it to a key, for example, <kbd>PrintScr</kbd> (code for Awesome WM):

```lua
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

## :free: License

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

---

¹: it is being recorded in lossless `AVI` and then converted to `WEBM`
