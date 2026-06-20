{
  lib,
  pkgs,
  config,
  username,
  mainDomain,
  ...
}:
let
  cfg = config.services.qbittorrent;
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

      AutoRun = {
        enabled = true;
        program = "${cfg.profileDir}scripts/autorun.sh %I";
      };
    };
  };

  systemd.services.qbittorrent.serviceConfig = {
    UMask = "0002";
    ExecStartPre = lib.mkAfter [
      "+${pkgs.coreutils}/bin/install -D -m 0550 -o ${cfg.user} -g ${cfg.group} ${
        config.sops.templates."qbittorrent-autorun-config.sh".path
      } ${cfg.profileDir}scripts/autorun.sh"
    ];
  };

  sops.templates."qbittorrent-autorun-config.sh" = {
    content =
      let
        inherit (config.services.cross-seed.settings) host port;
      in
      ''
        #!/bin/sh
        set -o errexit
        set -o nounset
        set -o pipefail

        ${lib.getExe pkgs.curl} \
          "http://${host}:${toString port}/api/webhook?apikey=${
            config.sops.placeholder."cross-seed/apiKey"
          }" \
          -XPOST \
          -d "infoHash=$1" \
          -d "includeSingleEpisodes=true"
      '';
  };

  networking.firewall.interfaces."wg-${tunnels}" = {
    allowedTCPPorts = [ cfg.serverConfig.BitTorrent.Session.Port ];
    allowedUDPPorts = [ cfg.serverConfig.BitTorrent.Session.Port ];
  };

  custom.services.haproxy = {
    backends = [
      {
        name = "qbittorrent";
        mode = "http";
        servers = [
          {
            name = "server1";
            addr = "127.0.0.1:${toString cfg.webuiPort}";
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
