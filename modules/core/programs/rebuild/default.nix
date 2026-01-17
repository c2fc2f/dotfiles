{
  pkgs,
  nh,
  lib,
  clib,
  username,
  hostName,
  systemInfo,
  ...
}:
with lib;
let
  serverHosts = filter (
    name:
    elem "server" systemInfo.${name}.groups
    && !(elem "iso" systemInfo.${name}.groups)
    && name != hostName
  ) (attrNames systemInfo);

  genCase = name: ''
    ${name} )
      nh os switch \
        --hostname ${name} \
        --build-host ${username}@sisyphe.sagbot.com \
        --target-host ${username}@${name}.sagbot.com
      ;;
  '';

in
{
  home-manager.users.${username} = {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "rebuild";

        runtimeInputs = [
          nh.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];

        text = ''
          case "''${1-}" in
            "" )
              nh os switch \
                --hostname ${hostName} \
                --build-host ${username}@sisyphe.sagbot.com
              ;;
            local )
              nh os switch
              ;;
          ${clib.indent 2 (concatStringsSep "" (map genCase serverHosts))}
            * )
              echo "Usage: $0 [local|${concatStringsSep "|" serverHosts}]"
              echo ""

              echo "Rebuild the configuration and switch to it"
              echo "  By default it use sisyphe.sagbot.com as the builder"
              exit 1
              ;;
          esac
        '';
      })
    ];
  };
}
