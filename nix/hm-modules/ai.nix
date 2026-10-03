{ inputs, config, pkgs, ... }:
{
  imports = [
    inputs.pi.homeModules.default
  ];
  programs.pi.coding-agent = {
    enable = true;
  };
}
