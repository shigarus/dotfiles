{ config, pkgs, ... }:
{
  imports = [
    ../../hm-modules/generic.nix
  ];
	launchd.agents.shigarus-ivm = {
		enable = true;
		config = {
			Label = "org.shigarus.ssh-ivm";
			# Load the external nsh installation from the user's shell PATH.
			ProgramArguments = [
				"/bin/zsh"
				"-lic"
				# 10350 for nebius stuff
				# 1455 codex
				# 3118 slack mcp login
				# 37783 onyx
				# 44321 nsh port, have to be set in shell envs
				# 44333 my rex server
				"exec nsh expect-url ssh shigarus-ivm -X -A -L 3118:localhost:3118 -L 1455:localhost:1455 -L 10351:localhost:10350 -L 37783:localhost:37783 -L 44321:localhost:44321 -L 44333:localhost:44333"
			];
			RunAtLoad = true;
			KeepAlive = true;
			ThrottleInterval = 30;
			LimitLoadToSessionType = "Aqua";
			WorkingDirectory = config.home.homeDirectory;
			StandardOutPath = "${config.home.homeDirectory}/Library/Logs/shigarus-ivm.log";
			StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/shigarus-ivm.error.log";
		};
	};
}
