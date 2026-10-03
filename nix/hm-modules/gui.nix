{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    gimp
    keymapp # zsa oryx
  ];
}
