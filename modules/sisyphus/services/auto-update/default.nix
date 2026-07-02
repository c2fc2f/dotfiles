{
  pkgs,
  lib,
  config,
  rootDomain,
  username,
  ...
}:

{
  systemd = {
    services.auto-update = {
      description = "Auto-Update Service";

      unitConfig.OnFailure = "notify-failure@%n";

      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.getExe (
          pkgs.writeShellApplication {
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

              git clone "https://${username}:''${PERSONAL_TOKEN}@github.com/${username}/dotfiles.git" dotfiles

              cd dotfiles

              echo "''${GPG_PRIVATE_KEY}" | base64 -d | gpg --batch --import
              KEY_ID=$(
                gpg --list-secret-keys --with-colons  \
                | awk -F: '/^sec/ {print $5; exit}'
              )

              git config user.name "${username}"
              git config user.email "culottes@${rootDomain}"
              git config user.signingkey "$KEY_ID"
              git config commit.gpgsign true

              export NIX_CONFIG="access-tokens = github.com=''${PERSONAL_TOKEN}"
              chmod +x ci/update.sh
              ./ci/update.sh

              retry -t 3 -d 2 -- bash -c 'git pull --rebase origin main && git push origin main'
            '';
          }
        );

        # Security & Isolation
        DynamicUser = true;
        RuntimeDirectory = "auto-update";
        WorkingDirectory = "/run/auto-update";
        PrivateTmp = true;
        EnvironmentFile = config.sops.secrets."auto-update/env".path;

        SupplementaryGroups = [ "nixbld" ];
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
  };
}
