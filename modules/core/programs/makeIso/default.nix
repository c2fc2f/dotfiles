{
  pkgs,
  lib,
  clib,
  username,
  systemInfo,
  ...
}:
with lib;
let
  isoHosts = builtins.filter (name: builtins.elem "iso" systemInfo.${name}.groups) (
    builtins.attrNames systemInfo
  );

  genCase = name: ''
    ${name} )
      nix build ~/git/dotfiles#nixosConfigurations.${name}.config.system.build.isoImage "''${@:2}"
      ;;
  '';
in
{
  home-manager.users.${username} = {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "makeIso";
        text = ''
          case "''${1-}" in
          ${clib.indent 2 (concatStringsSep "" (map genCase isoHosts))}
            * )
              echo "Usage: $0 [${concatStringsSep "|" isoHosts}]"
              exit 1
              ;;
          esac
        '';
      })
    ];
  };
}
