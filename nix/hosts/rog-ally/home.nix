{ inputs, config, pkgs, ... }:

{
  targets.genericLinux.enable = true;
  imports = [
    # ../../hm-modules/desktop.nix
    ../../hm-modules/generic.nix
    ../../hm-modules/hyprland-after-install.nix
    ../../hm-modules/fish.nix
    ../../hm-modules/gui.nix
    ../../hm-modules/programmin.nix
    ../../hm-modules/ai.nix
    ../../hm-modules/remote-descktop-client.nix
  ];
}
