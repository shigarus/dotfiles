#!/usr/bin/env bash

apps_transparent="(Zen|Ghostty|Slack)"
apps_transp_ignore="(kitty|Telegram|Obsidian)"
display_resolution=$(system_profiler SPDisplaysDataType | grep Resolution)
apps_mgoff_below="(Calculator|iStat Menus|Hammerspoon|BetterDisplay|GIMP|Notes|Activity Monitor|App StoreSoftware Update|TestRig|Gemini|Raycast|OBS Studio|Microsoft Edge|Cisco Packet Tracer|Stickies|kitty|ProLevel|Photo Booth|Hand Mirror|SteerMouse|remote-viewer|Jitsi Meet|DaVinci Resolve|Discord)"

# This keeps apps always on the top
apps_mgoff_above="()"
