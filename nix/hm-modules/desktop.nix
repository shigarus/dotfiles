{ inputs, config, pkgs, ... }:
{
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
  ];
  # kde plasma configuration
  programs.plasma = {
    enable = true;
    input.keyboard = {
      numlockOnStartup = "on";
      layouts = [ { layout = "us"; } { layout = "ru"; } ];
    };
    # Does not work my way, always opens new application instead of switching.
    # Plasma has only way of pinnig apps to specific
    # doc positions and switching to them via Meta+Num.
    # While macos uses the sam shortcut to switch tabs withit one application.
    # hotkeys.commands."to-ghostty" = {
    #   name = "Ghostty";
    #   key = "Ctrl+Shift+Alt+k";
    #   command = "ghostty";
    # };
  };
}
