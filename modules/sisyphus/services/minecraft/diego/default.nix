{
  pkgs,
  lib,
  config,
  rootDomain,
  nix-minecraft,
  ...
}:
let
  name = "diego";

  inherit (nix-minecraft.lib) collectFilesAt;

  modpack = pkgs.fetchModrinthModpack {
    src = ./_modpack/1.0.0.mrpack;
    packHash = "sha256-wTSZWzDsIHF56DtGMIzMeoa32E9XygfnN9dzt+hGO6Y=";
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

    jvmOpts = "-Xms12G -Xmx12G -XX:+UseG1GC -XX:G1PeriodicGCInterval=10000 -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200";

    symlinks = collectFilesAt modpack "mods" // {
      "mods/Chunky-Fabric.jar" = pkgs.fetchurl rec {
        pname = "Chunky-Fabric";
        version = "1.4.23";
        url = "https://cdn.modrinth.com/data/fALzjamp/versions/RVFHfo1D/${pname}-${version}.jar";
        hash = "sha256-NBKxcCR93nNR4JRdhX5xO+32+uBaswCqdNBv+94MoH4=";
      };
      "mods/c2me-fabric-mc1.21.1.jar" = pkgs.fetchurl rec {
        pname = "c2me-fabric-mc1.21.1";
        version = "0.4.0-alpha.0.30";
        url = "https://cdn.modrinth.com/data/VSNURh3q/versions/KxcgERSN/${pname}-${version}.jar";
        hash = "sha256-8TX1gqlyScI9xlAZATXJt4UTMcsyHuE60mjYvYAtORE=";
      };
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
