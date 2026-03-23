{
  pkgs,
  lib,
  config,
  mainDomain,
  ...
}:

let
  autoUpdateScript = pkgs.writeShellApplication {
    name = "auto-update-task";
    runtimeInputs = with pkgs; [
      git
      gnupg
      nix
      coreutils
      busybox
      bash
      curl
      jq
      retry
    ];
    text = ''
      HOME="$(pwd)"
      export HOME

      git clone "https://c2fc2f:''${PERSONAL_TOKEN}@github.com/c2fc2f/dotfiles.git" dotfiles

      cd dotfiles

      echo "''${GPG_PRIVATE_KEY}" | base64 -d | gpg --batch --import
      KEY_ID=$(
        gpg --list-secret-keys --with-colons  \
        | awk -F: '/^sec/ {print $5; exit}'
      )

      git config user.name "c2fc2f"
      git config user.email "culottes@sagbot.com"
      git config user.signingkey "$KEY_ID"
      git config commit.gpgsign true

      export NIX_CONFIG="access-tokens = github.com=''${PERSONAL_TOKEN}"
      chmod +x ci/update.sh
      ./ci/update.sh

      retry -t 3 -d 2 -- bash -c 'git pull --rebase origin main && git push origin main'
    '';
  };

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
  systemd = {
    services.auto-update = {
      description = "Auto-Update Service";

      unitConfig.OnFailure = "notify-failure@%n";

      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.getExe autoUpdateScript;

        # Security & Isolation
        DynamicUser = true;
        RuntimeDirectory = "auto-update";
        WorkingDirectory = "/run/auto-update";
        PrivateTmp = true;
        EnvironmentFile = config.sops.secrets."auto-update/env".path;

        SupplementaryGroups = [
          "nixbld"
        ];
      };
    };

    timers.auto-update = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*:0/5";
        Unit = "auto-update.service";
        Persistent = true;
      };
    };

    services."notify-failure@" = {
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
  };
}
