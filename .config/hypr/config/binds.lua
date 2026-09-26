local mainMod = "SUPER + CONTROL"
local super = "SUPER"
local meh = "CONTROL + ALT + SHIFT"
local noctCall = "noctalia msg "
local launchPrefix = "uwsm app -- " -- if you are not using UWSM, make this empty (e.g. "")

-- AZERTY fix: the number-row keys emit symbols (& é " ' ...) without Shift, so
-- binding to the digit characters fails. Bind by physical keycode instead.
-- Digit d -> evdev keycode: 1..9 => 10..18, 0 => 19
local function digitCode(d)
	return "code:" .. (d == 0 and 19 or (9 + d))
end

---------------------------
---- WINDOW MANAGEMENT ----
---------------------------

-- Window manipulation
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("hyprctl kill"))
hl.bind(super .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D", hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Change focus
hl.bind(super .. " + Left", hl.dsp.focus({ direction = "left" }))
hl.bind(super .. " + Right", hl.dsp.focus({ direction = "right" }))
hl.bind(super .. " + Up", hl.dsp.focus({ direction = "up" }))
hl.bind(super .. " + Down", hl.dsp.focus({ direction = "down" }))
hl.bind("ALT + Tab", hl.dsp.window.cycle_next())
hl.bind(super .. " + Tab", hl.dsp.exec_cmd(noctCall .. "window-switcher"))

-- Move active window around workspaces & monitors
hl.bind(super .. " + SHIFT + Up", hl.dsp.window.move({ direction = "u" }))
hl.bind(super .. " + SHIFT + Right", hl.dsp.window.move({ direction = "r" }))
hl.bind(super .. " + SHIFT + Left", hl.dsp.window.move({ direction = "l" }))
hl.bind(super .. " + SHIFT + Down", hl.dsp.window.move({ direction = "d" }))

-- Move & Resize with mouse
hl.bind(super .. " + mouse:272", hl.dsp.window.drag())
hl.bind(super .. " + mouse:273", hl.dsp.window.resize())

-- Zoom
local function zoomfunction(value)
	local zoomvalue = hl.get_config("cursor:zoom_factor")
	if (zoomvalue + value) > 3.0 then
		hl.config({ cursor = { zoom_factor = 3.0 } })
	elseif (zoomvalue + value) < 1.0 then
		hl.config({ cursor = { zoom_factor = 1.0 } })
	else
		hl.config({ cursor = { zoom_factor = zoomvalue + value } })
	end
end
hl.bind(mainMod .. " + Minus", function()
	zoomfunction(-0.3)
end, { repeating = true })
hl.bind(mainMod .. " + Plus", function()
	zoomfunction(0.3)
end, { repeating = true })

--# Zoom with keypad
hl.bind(mainMod .. " + code:82", function()
	zoomfunction(-0.3)
end, { repeating = true })
hl.bind(mainMod .. " + code:86", function()
	zoomfunction(0.3)
end, { repeating = true })

------------------
---- LAUNCHER ----
------------------

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(launchPrefix .. TERMINAL))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(launchPrefix .. FILE_MANAGER))
hl.bind("CONTROL + SHIFT + Escape", hl.dsp.exec_cmd(launchPrefix .. TERMINAL .. " -e btop"))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd(noctCall .. "settings-toggle"))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd(noctCall .. "panel-toggle control-center"))
hl.bind(super .. " + Space", hl.dsp.exec_cmd(noctCall .. "panel-toggle launcher"))
hl.bind(mainMod .. " + period", hl.dsp.exec_cmd(noctCall .. "panel-toggle launcher /emo"))
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(noctCall .. "session lock"))
hl.bind(super .. " + ALT + C", hl.dsp.exec_cmd(noctCall .. "panel-toggle session"))

---------------------------
---- HARDWARE CONTROLS ----
---------------------------

-- Audio
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(noctCall .. "volume-up"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(noctCall .. "volume-down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(noctCall .. "volume-mute"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(noctCall .. "mic-mute"), { locked = true })

-- Media
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(noctCall .. "media toggle"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(noctCall .. "media toggle"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(noctCall .. "media next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(noctCall .. "media previous"), { locked = true })

-- Brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(noctCall .. "brightness-up"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(noctCall .. "brightness-down"), { locked = true, repeating = true })

-------------------
---- UTILITIES ----
-------------------

-- Screen Capture
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("hyprpicker -a -n"))
hl.bind("Print", hl.dsp.exec_cmd(noctCall .. "screenshot-region"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd(noctCall .. "screenshot-fullscreen"))

-- Theming and Wallpaper
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(noctCall .. "panel-toggle wallpaper"))

-- Clipboard
hl.bind(super .. " + SHIFT + V", hl.dsp.exec_cmd(noctCall .. "panel-toggle clipboard"))

-- Notifications
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(noctCall .. "panel-toggle control-center notifications"))

-------------------------------
---- WORKSPACES & MONITORS ----
-------------------------------

-- Focus on prebuilt workspaces
hl.bind(meh .. " + J", hl.dsp.focus({ workspace = "name:browser" }))
hl.bind(meh .. " + K", hl.dsp.focus({ workspace = "name:term" }))
hl.bind(meh .. " + I", hl.dsp.focus({ workspace = "name:tg" }))
hl.bind(meh .. " + Y", hl.dsp.focus({ workspace = "name:default" }))

-- Move to adjacent workspaces and next empty on a given monitor
hl.bind(mainMod .. " + Right", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + Left", hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + Down", hl.dsp.focus({ workspace = "emptym" }))

-- Scroll through existing workspaces & monitors
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + CONTROL + mouse_up", hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + CONTROL + mouse_down", hl.dsp.focus({ workspace = "m+1" }))

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special" }))
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special())

------------
---Device---
------------

hl.bind(meh .. " + E", hl.dsp.exec_cmd("hyprctl switchxkblayout current 0"))
hl.bind(meh .. " + R", hl.dsp.exec_cmd("hyprctl switchxkblayout current 1"))

----------------------
---Mac OS emulation---
----------------------
hl.bind(super .. " + W", hl.dsp.send_shortcut({ mods = "CTRL", key = "W" }))
hl.bind(super .. " + R", hl.dsp.send_shortcut({ mods = "CTRL", key = "R" }))
hl.bind(super .. " + T", hl.dsp.send_shortcut({ mods = "CTRL", key = "T" }))
hl.bind(super .. " + A", hl.dsp.send_shortcut({ mods = "CTRL", key = "A" }))
hl.bind(super .. " + S", hl.dsp.send_shortcut({ mods = "CTRL", key = "S" }))
hl.bind(super .. " + F", hl.dsp.send_shortcut({ mods = "CTRL", key = "F" }))
hl.bind(super .. " + G", hl.dsp.send_shortcut({ mods = "CTRL", key = "G" }))
hl.bind(super .. " + Z", hl.dsp.send_shortcut({ mods = "CTRL", key = "Z" }))
hl.bind(super .. " + X", hl.dsp.send_shortcut({ mods = "CTRL", key = "X" }))
hl.bind(super .. " + B", hl.dsp.send_shortcut({ mods = "CTRL", key = "B" }))
hl.bind(super .. " + L", hl.dsp.send_shortcut({ mods = "CTRL", key = "L" }))
hl.bind(super .. " + C", hl.dsp.send_shortcut({ mods = "CTRL", key = "Insert" }))
hl.bind(super .. " + V", hl.dsp.send_shortcut({ mods = "SHIFT", key = "Insert" }))
hl.bind(super .. " + SHIFT + Z", hl.dsp.send_shortcut({ mods = "CTRL", key = "Y" }))
