{
  pkgs,
  config,
  lib,
  nix-minecraft,
  rootDomain,
  ...
}:
let
  name = "jade";

  inherit (nix-minecraft.lib) collectFilesAt;

  version = "1.20.1-47.4.10";
  installer = pkgs.fetchurl {
    pname = "forge-installer";
    inherit version;
    url = "https://maven.minecraftforge.net/net/minecraftforge/forge/${version}/forge-${version}-installer.jar";
    hash = "sha256-GRJ2C0y2uAPYqCbeYDyQdrHacewnZemh+MHKePZSeOM=";
  };
  java = pkgs.openjdk21;
  forgeServer = pkgs.writeShellScriptBin "forge-server" ''
    if ! [ -e "libraries" ]; then
      echo "Installing Forge server..."
      ${lib.getExe java} -jar ${installer} --installServer
    fi
    exec ${lib.getExe java} "$@" @libraries/net/minecraftforge/forge/${version}/unix_args.txt nogui
  '';
in
{
  services.minecraft-servers.servers.${name} = {
    enable = true;
    autoStart = true;
    restart = "always";

    package = forgeServer;

    jvmOpts = "-Xmx6G";

    symlinks = collectFilesAt ./_modpack "mods";
    files = collectFilesAt ./_modpack "config" // {
      "server-icon.png" = builtins.path {
        name = "server-icon.png";
        path = ./_modpack/server-icon.png;
      };
    };

    serverProperties = {
      server-port = 25567;
      "query.port" = 25567;

      allow-flight = true;

      difficulty = "easy";
      gamemode = "survival";
      pvp = true;
      online-mode = true;
      spawn-protection = 0;
      white-list = false;
      max-players = 69;
      enable-command-block = true;
      motd = "Serveur de Jade";
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
