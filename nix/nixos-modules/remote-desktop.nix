{ config, lib, ... }:
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

    users.users.${config.remote-desktop.user}.extraGroups = [
      "uinput"
    ];

    hardware.uinput.enable = true;
  };
}
