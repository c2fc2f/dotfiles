{
  pkgs,
  config,
  lib,
  nix-minecraft,
  mainDomain,
  ...
}:
let
  name = "osr2";

  inherit (nix-minecraft.lib) collectFilesAt;

  modpack = pkgs.fetchzip {
    url = "https://sagbot.com/OSR2-1.4.1-Server.zip";
    hash = "sha256-9rrG2E1KyPLGfMq1CH9h6ygCxMC5C8EqF26CzyuEvH8=";
  };

  version = "21.1.219";
  installer = pkgs.fetchurl {
    pname = "forge-installer";
    inherit version;
    url = "https://maven.neoforged.net/releases/net/neoforged/neoforge/${version}/neoforge-${version}-installer.jar";
    hash = "sha256-FA3w+hf9Q4hIBR7Po9CRCBUVrRK/40+hJkBQN7oB3kQ=";
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

    symlinks = collectFilesAt modpack "mods";
    files =
      collectFilesAt modpack "config"
      // collectFilesAt modpack "kubejs"
      // {
        "server-icon.png" = "${modpack}/server-icon.png";
      };

    serverProperties = {
      server-port = 25567;
      "query.port" = 25567;

      allow-flight = true;

      broadcast-rcon-to-ops = true;
      difficulty = "hard";
      enable-command-block = true;
      enable-jmx-monitoring = false;
      enable-query = false;
      enable-rcon = false;
      enable-status = true;
      enforce-secure-profile = true;
      enforce-whitelist = false;
      entity-broadcast-range-percentage = 100;
      force-gamemode = false;
      function-permission-level = 2;
      gamemode = "survival";
      generate-structures = true;
      hardcore = false;
      hide-online-players = false;
      level-name = "world";
      level-type = "skyblockbuilder:skyblock";
      max-chained-neighbor-updates = 1000000;
      max-players = 69;
      max-tick-time = 60000;
      max-world-size = 29999984;
      motd = "Ozone Skyblock Reborn 2";
      network-compression-threshold = 256;
      online-mode = true;
      op-permission-level = 4;
      player-idle-timeout = 0;
      prevent-proxy-connections = false;
      pvp = true;
      rate-limit = 0;
      require-resource-pack = false;
      simulation-distance = 4;
      spawn-animals = true;
      spawn-monsters = true;
      spawn-npcs = true;
      spawn-protection = 0;
      sync-chunk-writes = true;
      use-native-transport = true;
      view-distance = 7;
      white-list = false;
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
