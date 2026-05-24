{
  lib,
  pkgs,
  mainDomain,
  ...
}:
let
  notifyScript = pkgs.writeShellApplication {
    name = "send-failure-email";
    runtimeInputs = with pkgs; [
      msmtp
      hostname
      systemd
    ];
    text = ''
      SERVICE_NAME="''${1:-unknown-service}"
      EMAIL_TO="contact@${mainDomain}"
      EMAIL_FROM="nixos-automation@$(hostname)"

      msmtp --host=localhost \
            --port=25 \
            --auth=off \
            --from="$EMAIL_FROM" \
            -t <<EOF
      To: $EMAIL_TO
      Subject: [NixOS Failure] Service $SERVICE_NAME failed

      The systemd service $SERVICE_NAME has failed on $(date).
      Check logs: journalctl -u $SERVICE_NAME -I

      $(journalctl -u "$SERVICE_NAME" -I)
      EOF
    '';
  };
in
{
  systemd.services."notify-failure@" = {
    description = "Send raw SMTP notification for %i";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lib.getExe notifyScript} %i";
      DynamicUser = true;

      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
      ];

      SupplementaryGroups = [ "systemd-journal" ];
    };
  };
}
