{ config, ... }:

{
  services.lidarr = {
    enable = true;

    settings = {
      server = {
        bindAddress = "127.0.0.86";
      };
    };
  };

  users.groups.qbittorrent.members = [
    config.services.lidarr.user
  ];

  systemd.tmpfiles.rules =
    let
      inherit (config.services.navidrome.settings) MusicFolder;
      inherit (config.services.lidarr) user;
    in
    [
      "a+ ${MusicFolder} - - - - user:${user}:rwx"
    ];

  custom.services.haproxy = {
    backends = [
      {
        name = "lidarr";
        mode = "http";
        servers =
          let
            inherit (config.services.lidarr.settings.server) bindAddress port;
          in
          [

            {
              name = "server1";
              addr = "${bindAddress}:${toString port}";
              check = true;
            }
          ];
      }
    ];

    maps = {
      url = [
        {
          url = "manager.sagbot.com";
          backend = "lidarr";
        }
      ];
    };
  };
}
