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

    serverConfig = {
      LegalNotice.Accepted = true;
      Preferences = {
        WebUI = {
          Username = username;
          Password_PBKDF2 = "\"@ByteArray(Mg/kCHd5eampa5IdkFMdjw==:KEBxmjtHR8xLDopCh2RZT+dpHgOUqFE/9qm7nqDtMNQsg1L/lNzLfxFTHrZYCsfMIMOMCsqnb2DTyTmO8znF6w==)\"";
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
