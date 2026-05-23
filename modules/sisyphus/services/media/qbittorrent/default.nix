{
  config,
  username,
  mainDomain,
  ...
}:

{
  services.qbittorrent = {
    enable = true;

    webuiPort = 8113;
    group = "media";

    serverConfig = {
      LegalNotice.Accepted = true;
      Preferences = {
        WebUI = {
          Username = username;
          Password_PBKDF2 = "\"@ByteArray(N1H1mfNGSNxXT6RqaQXDsQ==:l/u/nZ/giFlPrUqW9oj/GPykVuBYjaMf5bHj0+/Zsn1xOx6ZKwThToNyyDtl6p80a6UyUzo6RoQnxJKhcxz7SA==)\"";
        };
        General.Locale = "en";
      };
    };
  };

  custom.services.haproxy = {
    backends = [
      {
        name = "qbittorrent";
        mode = "http";
        servers =
          let
            inherit (config.services.qbittorrent) webuiPort;
          in
          [

            {
              name = "server1";
              addr = "127.0.0.1:${toString webuiPort}";
              check = true;
            }
          ];
      }
    ];

    maps = {
      url = [
        {
          url = "torrent.${mainDomain}";
          backend = "qbittorrent";
        }
      ];
    };
  };
}
