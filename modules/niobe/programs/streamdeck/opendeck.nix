{
  pkgs,
  lib,
  username,
  opendeck-nix,
  ...
}:

{
  imports = [ opendeck-nix.nixosModules.default ];
  programs.opendeck.enable = true;

  home-manager.users.${username} = {
    systemd.user.services.opendeck = {
      Unit = {
        Description = "OpenDeck";
        After = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${lib.getExe
          opendeck-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
        }";
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
