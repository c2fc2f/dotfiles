{ config, username, ... }:

{
  imports = [
    # keep-sorted start
    ./secrets
    # keep-sorted end
  ];

  services.navidrome = {
    enable = true;

    environmentFile = config.sops.secrets."navidrome/env".path;

    settings = {
      MusicFolder = "/var/lib/music";
      "Scanner.Schedule" = "@every 15m";
      "LastFM.Enabled" = true;

      Address = "127.0.0.110";
      Port = 4110;

      EnableInsightsCollector = true;
    };
  };

  systemd.tmpfiles.rules =
    let
      inherit (config.services.navidrome.settings) MusicFolder;
      inherit (config.services.navidrome) user group;
    in
    [
      "d ${MusicFolder} 0775 ${user} ${group} -"
      "A+ ${MusicFolder} - - - - user:${username}:rwx"
      "A+ ${MusicFolder} - - - - default:user:${username}:rwx"
    ];

  custom.services.haproxy = {
    backends = [
      {
        name = "navidrome";
        mode = "http";
        servers =
          let
            inherit (config.services.navidrome.settings) Address Port;
          in
          [

            {
              name = "server1";
              addr = "${Address}:${toString Port}";
              check = true;
            }
          ];
      }
    ];

    maps = {
      url = [
        {
          url = "music.sagbot.com";
          backend = "navidrome";
        }
      ];
    };
  };
}
