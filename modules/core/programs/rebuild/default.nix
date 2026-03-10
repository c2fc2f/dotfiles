{
  pkgs,
  nh,
  lib,
  clib,
  username,
  hostName,
  systemInfo,
  builder,
  mainDomain,
  ...
}:
with lib;
let
  serverHosts = filter (name: elem "server" systemInfo.${name}.groups && name != hostName) (
    attrNames systemInfo
  );

  genCase = name: ''
    ${name} )
      case "$BUILDER_ARG" in
        local )
          nh os switch \
            --hostname ${name} \
            --target-host ${username}@${name}.${mainDomain}
        ;;
        self )
          nh os switch \
            --hostname ${name} \
            --build-host ${username}@${name}.${mainDomain} \
            --target-host ${username}@${name}.${mainDomain}
        ;;
        * )
          nh os switch \
            --hostname ${name} \
            --build-host ${username}@"$BUILDER_ARG".${mainDomain} \
            --target-host ${username}@${name}.${mainDomain}
        ;;
        esac
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
          BUILDER_ARG="${builder}"
          TARGET_HOST_ARG=""

          while [[ $# -gt 0 ]]; do
            case "$1" in
              --builder)
                if [[ -n "''${2-}" && ! "$2" =~ ^- ]]; then
                  BUILDER_ARG="$2"
                  shift 2
                else
                  echo "Error: --builder requires a value."
                  exit 1
                fi
                ;;
              *)
                TARGET_HOST_ARG="$1"
                shift
                ;;
            esac
          done

          TARGET_HOST_ARG=''${TARGET_HOST_ARG:-"${hostName}"}

          case "$TARGET_HOST_ARG" in
            local | "${hostName}" )
              if [[ "$BUILDER_ARG" = "local" || "$BUILDER_ARG" = "self" ]]; then
                nh os switch
              else
                nh os switch --build-host "${username}@$BUILDER_ARG.${mainDomain}"
              fi
              ;;
          ${clib.indent 2 (concatStringsSep "" (map genCase serverHosts))}
            * )
              echo "Usage: $0 [local|${concatStringsSep "|" serverHosts}] [--builder <hostname>|local|self]"
              echo ""
              echo "Default Builder: ${builder}"
              exit 1
              ;;
          esac
        '';
      })
    ];
  };
}
