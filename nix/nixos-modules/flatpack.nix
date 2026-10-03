{ config, pkgs, inputs, ... }:
{
  # Non-declarative, yes.
  # The only way to install zen
  # without writing build yourself is third party flake
  # which I don't want to use.
  systemd.services.flatpak-install-zen = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    serviceConfig.Type = "oneshot";
    script = ''
      flatpak remote-add --if-not-exists flathub \
        https://dl.flathub.org/repo/flathub.flatpakrepo

      flatpak install -y flathub app.zen_browser.zen
    '';
  };
  services.flatpak.enable = true;
}
