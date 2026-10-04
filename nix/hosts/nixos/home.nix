{ inputs, config, pkgs, ... }:

{
  imports = [
    ../../hm-modules/desktop.nix
    ../../hm-modules/generic.nix
    ../../hm-modules/gui.nix
    ../../hm-modules/programmin.nix
    ../../hm-modules/ai.nix
  ];
  home.packages = with pkgs; [
    tailscale
  ];

  home.file = {
    # Make ghostty font smaller due to weird monitor setup
    ".config/ghostty/custom".text = '' font-size = 18 '';
    ".home-assistant/cfg/.keep".text = "";
  };
}
