{
  config,
  username,
  mainDomain,
  ...
}:
let
  tunnels = "prometheus";
in
{
  services.qbittorrent = {
    enable = true;

    webuiPort = 8113;
    inherit (config.custom.media) group;

    serverConfig = {
      LegalNotice.Accepted = true;

      Preferences = {
        General.Locale = "en";

        WebUI = {
          Username = username;
          Password_PBKDF2 = "\"@ByteArray(N1H1mfNGSNxXT6RqaQXDsQ==:l/u/nZ/giFlPrUqW9oj/GPykVuBYjaMf5bHj0+/Zsn1xOx6ZKwThToNyyDtl6p80a6UyUzo6RoQnxJKhcxz7SA==)\"";
        };
      };

      Meta = {
        MigrationVersion = 8;
      };

      Core = {
        AutoDeleteAddedTorrentFile = "Never";
      };

      BitTorrent = {
        Session = {
          DefaultSavePath = "${config.custom.media.directory}/downloads";

          AnnounceToAllTrackers = true;

          Port = 51413;
          ProxyPeerConnections = false;
          QueueingSystemEnabled = false;
          Interface = "wg-${tunnels}";
          InterfaceName = "wg-${tunnels}";
        };
      };

      Network = {
        Proxy = {
          IP = "${tunnels}.proxy";
          Port = 1080;
          Type = "SOCKS5";
          AuthEnabled = false;

          HostnameLookupEnabled = true;
          Profiles = {
            BitTorrent = false;
            Misc = false;
            RSS = false;
          };
        };
      };
    };
  };

  systemd.services.qbittorrent.serviceConfig.UMask = "0002";

  networking.firewall.interfaces."wg-${tunnels}" = {
    allowedTCPPorts = [
      config.services.qbittorrent.serverConfig.BitTorrent.Session.Port
    ];
    allowedUDPPorts = [
      config.services.qbittorrent.serverConfig.BitTorrent.Session.Port
    ];
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
