{
  pkgs,
  lib,
  config,
  rootDomain,
  username,
  ...
}:
let
  name = "dotfiles-ci";
in
{
  systemd = {
    services.${name} = {
      description = "Dotfiles CI Orchestrator";

      unitConfig.OnFailure = "notify-failure@%n";

      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "oneshot";

        DynamicUser = true;
        SupplementaryGroups = [ "nixbld" ];

        RuntimeDirectory = name;
        WorkingDirectory = "/run/${name}";
        PrivateTmp = true;

        EnvironmentFile = config.sops.secrets."${name}/env".path;

        ExecStart = lib.getExe (
          pkgs.writeShellApplication {
            name = "${name}-orchestrator";
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
              export NIX_CONFIG="access-tokens = github.com=''${PERSONAL_TOKEN}"

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

              chmod +x ci/*.sh

              ./ci/update.sh

              retry -t 3 -d 2 -- bash -c 'git pull --rebase origin main && git push origin main'
            '';
          }
        );
      };
    };

    timers.${name} = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*:0/5";
        Unit = "${name}.service";
        Persistent = true;
      };
    };
  };
}
