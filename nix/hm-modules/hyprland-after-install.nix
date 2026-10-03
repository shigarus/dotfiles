{ config, pkgs, ... }:
{
  systemd.user.services.hyprland-single-monitor = {
    Unit = {
      Description = "Disables first monitor when adding second.";
    };
    Service = {
      ExecStart = "${pkgs.writeShellScript "hyprland-single-monitor" ''
        #!/bin/sh
		check_monitors() {
			# Count connected monitors using hyprctl JSON output
			count=$(hyprctl monitors -j | jq length)
			
			# Adjust 'eDP-1' to your built-in monitor name
			if [ "$count" -gt 1 ]; then
				hyprctl dispatch 'hl.dsp.dpms({action="disable", monitor="eDP-1"})'
        hyprctl workspaces -j |
          jq -r '.[] | select(.monitor == "eDP-1" and .ispersistent) | .name' |
          xargs -I{} sh -c 'hyprctl dispatch "hl.dsp.workspace.move({workspace=\"name:$1\",monitor=\"DP-2\"})"' _ {}
			else
				hyprctl dispatch 'hl.dsp.dpms({action="enable", monitor="eDP-1"})'
        hyprctl workspaces -j |
          jq -r '.[] | select(.monitor != "eDP-1" and .ispersistent) | .name' |
          xargs -I{} sh -c 'hyprctl dispatch "hl.dsp.workspace.move({workspace=\"name:$1\",monitor=\"eDP-1\"})"' _ {}
			fi
		}

		# Run once at startup
		check_monitors

		handle() {
		  case $1 in
			monitoradded* | monitorremoved* ) check_monitors ;;
		  esac
		}

		socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done
      ''}";
    };
  };
}
