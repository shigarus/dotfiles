{ config, pkgs, ... }:
{
  imports = [
    ../../hm-modules/generic.nix
  ];
	launchd.agents.shigarus-ivm = {
		enable = true;
		config = {
			Label = "org.shigarus.ssh-ivm";
			# Load rex and jq from the user's local shell PATH. The visible Rex
			# session owns SSH; launchd only ensures that the session exists.
			ProgramArguments = [
				"/bin/zsh"
				"-lic"
				"exec bash ${pkgs.writeShellScript "ensure-ivm-session" (builtins.readFile ../../../.config/rex/scripts/ensure-ivm-session.sh)} ${pkgs.writeShellScript "ivm-tunnel" (builtins.readFile ../../../.config/rex/scripts/ivm-tunnel.sh)}"
			];
			RunAtLoad = true;
			KeepAlive = false;
			StartInterval = 30;
			LimitLoadToSessionType = "Aqua";
			WorkingDirectory = config.home.homeDirectory;
			StandardOutPath = "${config.home.homeDirectory}/Library/Logs/shigarus-ivm.log";
			StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/shigarus-ivm.error.log";
		};
	};
}
