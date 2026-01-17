{
  pkgs,
  username,
  config,
  ...
}:

{
  home-manager.users.${username} = {
    home.packages = [
      (pkgs.writeShellScriptBin "update" ''
        #!/usr/bin/env bash

        set -euo pipefail

        case "''\${1-}" in
          commit )
            git commit -m "chore(flake.lock): update dependencies" -n
            ;;
          * )
            NIX_CONFIG="access-tokens = github.com=$(cat ${
              config.sops.secrets."github/token/readonly".path
            })" nix flake update --flake ~/git/dotfiles/ "$@"
            ;;
        esac
      '')
    ];
  };
}
