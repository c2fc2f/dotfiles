{
  pkgs,
  config,
  lib,
  mainDomain,
  ...
}:
let
  name = "pixelmon";

  version = "21.1.218";
  installer = pkgs.fetchurl {
    pname = "forge-installer";
    inherit version;
    url = "https://maven.neoforged.net/releases/net/neoforged/neoforge/${version}/neoforge-${version}-installer.jar";
    hash = "sha256-J9dpTWoPfkdNTGxbVcxb1ZQTIvLxWU+ZJ/+Vc9+5MyM=";
  };
  java = pkgs.openjdk21;
  neoforgeServer = pkgs.writeShellScriptBin "neoforge-server" ''
    if ! [ -e "libraries" ]; then
      echo "Installing NeoForge server..."
      ${lib.getExe java} -jar ${installer} --installServer
    fi
    exec ${lib.getExe java} "$@" @libraries/net/neoforged/neoforge/${version}/unix_args.txt nogui
  '';
in
{
  services.minecraft-servers.servers.${name} = {
    enable = true;
    autoStart = true;
    restart = "always";

    package = neoforgeServer;

    jvmOpts = "-Xmx6G";

    symlinks = {
      "mods/Pixelmon.jar" = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/59ZceYlU/versions/NknNQ3DN/Pixelmon-1.21.1-9.3.14-universal.jar";
        hash = "sha256-RALl0DhHshnrkxyOpKwYfJuq4r/ezx0V6Sx4WJ05D1w=";
      };
    };
    files = {
      "server-icon.png" = pkgs.fetchurl {
        url = "https://sagbot.com/pixelmon-server-icon.png";
        hash = "sha256-KY0HRc9M8Sze8VMYWipAl4jiHCEe7UNjcQfJ1IAiUNo=";
      };
    };

    serverProperties = {
      server-port = 25566;
      "query.port" = 25566;

      spawn-protection = 0;
      enable-command-block = true;
      allow-flight = true;
      view-distance = 16;
    };
  };

  custom.services.haproxy = {
    backends = [
      {
        inherit name;

        mode = "tcp";
        servers =
          let
            inherit (config.services.minecraft-servers.servers.${name}.serverProperties) server-port;
          in
          [

            {
              name = "server1";
              addr = "localhost:${toString server-port}";
              check = true;
            }
          ];
      }
    ];

    maps = {
      minecraft = [
        {
          url = "${name}.${mainDomain}";
          backend = name;
        }
      ];
    };
  };
}
