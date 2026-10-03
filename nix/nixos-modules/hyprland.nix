{ config, pkgs, inputs, ... }:
{
  imports = [
    inputs.noctalia.nixosModules.default
  ];

  environment.systemPackages = with pkgs; [
    qt6Packages.qt6ct
    xsettingsd
    gtk3
    gtk4
    xhost
    # Hyprland desktop utilities
    grim
    slurp
    wl-clipboard
    hyprpicker
    # Portals
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
  ];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };
  programs.noctalia = {
    enable = true;

    recommendedServices.enable = true;
    # launch_apps_as_systemd_services = true;
  };
}
