{
  username,
  pkgs,
  lib,
  ...
}:
/*
  SSH agent service, which securely stores private SSH keys in memory and
  handles authentication, so you don't have to re-enter your passphrase each
  time you connect to a server.
*/
let
  waylandAskpass = lib.getExe (
    pkgs.writeShellApplication {
      name = "wayland-askpass";
      runtimeInputs = with pkgs; [
        kdePackages.kdialog
        libnotify
      ];
      text = ''
        if echo "$1" | grep -iE 'pin|pass' > /dev/null; then
          kdialog --password "$1" 2> /dev/null
        else
          notify-send "SSH Authentication" "$1" --icon=dialog-information
          exit 0
        fi
      '';
    }
  );
in
{
  home-manager.users.${username} = {
    services.ssh-agent = {
      enable = true;
    };

    systemd.user.services.ssh-agent = {
      Service = {
        Environment = [
          "SSH_ASKPASS=${waylandAskpass}"
          "SSH_ASKPASS_REQUIRE=prefer"
        ];
      };

      Unit = {
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install.WantedBy = lib.mkForce [ "graphical-session.target" ];
    };
  };
}
