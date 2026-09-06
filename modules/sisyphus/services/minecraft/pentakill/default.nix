{
  pkgs,
  config,
  rootDomain,
  ...
}:
let
  name = "pentakill";

  modpack = pkgs.fetchModrinthModpack {
    src = ./_modpack/1.0.0.mrpack;
    packHash = "sha256-5PGMaiqOUk4V2H2B9ksmecH6jPTto6rzygMRvoLeWrw=";
    side = "client";
  };
in
{
  services.minecraft-servers.servers.${name} = {
    enable = true;

    package = pkgs.fabricServers.fabric-1_20_1;

    symlinks = {
      "mods" = "${modpack}/mods";
    };
    files = {
      "config" = "${modpack}/config";
    };

    serverProperties = {
      server-port = 25568;
      "query.port" = 25568;

      allow-flight = true;

      difficulty = "easy";
      gamemode = "survival";
      pvp = true;
      online-mode = true;
      spawn-protection = 0;
      white-list = false;
      max-players = 6769420;
      enable-command-block = true;
      motd = "PENTAKILL";
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
