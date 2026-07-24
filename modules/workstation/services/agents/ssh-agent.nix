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
        coreutils
        gnugrep
        procps
      ];
      text = ''
        current_pid=$PPID
        ssh_cmd=""

        while [ "$current_pid" -gt 1 ] && [ -r "/proc/$current_pid/stat" ]; do
          read -r _ comm _ ppid _ < "/proc/$current_pid/stat"

          if [ "$comm" = "(ssh)" ]; then
            ssh_cmd=$(tr '\0' ' ' < "/proc/$current_pid/cmdline")
            break

          if [ "$comm" = "(ssh-agent)" ]; then
            newest_ssh=$(pgrep -n -x ssh -a || true)
            if [ -n "$newest_ssh" ]; then
              ssh_cmd="(Guessed target) $(echo "$newest_ssh" | cut -d' ' -f2-)"
            fi
            break
          fi

          current_pid=$ppid
        done

        prompt="$1"
        if [ -n "$ssh_cmd" ]; then
          prompt="$prompt\n\nTarget command: $ssh_cmd"
        fi

        if echo "$1" | grep -iE 'pin|pass' > /dev/null; then
          kdialog --title "SSH Authentication" --password "$prompt" 2> /dev/null
        else
          notify-send "SSH Authentication" "$prompt" --icon=dialog-information
          exit 0
        fi
      '';
    }
  );
in
{
  home-manager.users.${username} = {
    home.sessionVariables = {
      SSH_ASKPASS = waylandAskpass;
      SSH_ASKPASS_REQUIRE = "prefer";
    };

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
