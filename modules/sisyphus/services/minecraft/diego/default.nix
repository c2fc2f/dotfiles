{
  pkgs,
  lib,
  config,
  rootDomain,
  ...
}:
let
  name = "diego";

  modpack = pkgs.fetchModrinthModpack {
    src = ./_modpack/1.0.0.mrpack;
    packHash = "sha256-TaZfwZNTKoYtj3/Yc1ana2HoiN/nBOs+3hSzCUxEpOg=";
    side = "both";
  };
  mcVersion = modpack.manifest.dependencies.minecraft;
  fabricVersion = modpack.manifest.dependencies.fabric-loader;
  serverVersion =
    lib.replaceStrings [ "." ] [ "_" ]
      "fabric-${mcVersion}";
in
{
  services.minecraft-servers.servers.${name} = {
    enable = true;

    package = pkgs.fabricServers.${serverVersion}.override {
      loaderVersion = fabricVersion;
    };

    jvmOpts = "-Xmx6G";

    symlinks = {
      "mods" = "${modpack}/mods";
    };
    files = {
      "config" = "${modpack}/config";
      "server-icon.png" = builtins.path {
        name = "server-icon.png";
        path = ./_modpack/server-icon.png;
      };
    };

    serverProperties = {
      server-port = 25568;
      "query.port" = 25568;

      allow-flight = true;

      difficulty = "hard";
      gamemode = "survival";
      pvp = true;
      online-mode = true;
      spawn-protection = 0;
      white-list = false;
      max-players = 6769420;
      enable-command-block = true;
      motd = "LA SURVIE TROP COOL VOILI VOILOUUUUUU";
    };
  };

  custom.services.haproxy = {
    backends = [
      {
        inherit name;

        mode = "tcp";
        servers =
          let
            inherit
              (config.services.minecraft-servers.servers.${name}.serverProperties)
              server-port
              ;
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
          url = "${name}.${rootDomain}";
          backend = name;
        }
      ];
    };
  };
}
