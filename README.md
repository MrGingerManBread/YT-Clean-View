# YT-Clean-View
AutoHotkey v2 script to open a YouTube link in your clipboard in DETURL's "Clean Viewer" webpage
1. Checks if clipboard is YT link
2. Opens link in DETURL's Clean Viewer webpage (using OS's default browser)
3. Tries to switch back to original tab

NOTE: It might be good to turn off your default browser's autoplay media setting so the newly loaded video tab doesn't start playing when it tries to switch back to the original tab.


### REQUIRES
[Descolada's v2 of UIA and UIA Browser](https://github.com/Descolada/UIA-v2/tree/main)

### Current Issue:
Doesn't see some tab names sometimes especially if they are pinned. So added TRY command in a couple places.
