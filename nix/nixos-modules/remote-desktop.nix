{ config, lib, ... }:
let
  cfg = config.remote-desktop;
in
{
  options.remote-desktop.user = lib.mkOption {
    type = lib.types.str;
    description = "User that runs Sunshine.";
  };

  config = {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
    };

    users.users.${cfg.user}.extraGroups = [
      "uinput"
    ];

    hardware.uinput.enable = true;
  };
}
