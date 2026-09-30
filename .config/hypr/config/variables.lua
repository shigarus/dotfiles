-- Hyprland default apps

TERMINAL = "ghostty"
FILE_MANAGER = "dolphin"
BROWSER = "zen-browser"
local handle = io.popen("hostname")
local hostname = handle and handle:read("*a"):gsub("%s+$", "") or ""
if handle then
	handle:close()
end
REDUCE_RAM = string.find(hostname, "homelab")
