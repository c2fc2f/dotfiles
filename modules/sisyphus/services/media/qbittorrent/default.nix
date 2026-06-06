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

          Port = 51413;
          ProxyPeerConnections = false;
          QueueingSystemEnabled = false;
          Interface = "wg-icarus";
          InterfaceName = "wg-icarus";
        };
      };

      Network = {
        Proxy = {
          IP = "icarus.proxy";
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

  networking.firewall.interfaces."wg-icarus" = {
    allowedTCPPorts = [
      config.services.qbittorrent.serverConfig.BitTorrent.Session.Port
    ];
    allowedUDPPorts = [
      config.services.qbittorrent.serverConfig.BitTorrent.Session.Port
    ];
  };

  networking.firewall.extraCommands =
    let
      inherit (config.services.qbittorrent) user;
    in
    ''
      iptables -t mangle -D OUTPUT -m owner --uid-owner ${user} -j MARK \
        --set-mark 0x21 2>/dev/null || true

      iptables -t mangle -A OUTPUT -m owner --uid-owner ${user} -j MARK \
        --set-mark 0x21
    '';

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
