{
  config,
  hostName,
  lib,
  ...
}:
let
  cfg = config.custom.vpn.servers.${hostName};
  users = lib.filterAttrs (
    name: _: name != hostName
  ) config.custom.vpn.users;
in
{
  config = lib.mkIf (config.custom.vpn.servers ? ${hostName}) {
    systemd.network = {
      networks."50-wg0" = {
        matchConfig.Name = "wg0";

        address = [
          "${cfg.address.private.ipv4}1/32"
        ]
        ++ (lib.optional (
          cfg.address.private.ipv6 != null
        ) "${cfg.address.private.ipv6}1/64");

        networkConfig = {
          IPv4Forwarding = true;
          IPv6Forwarding = true;
        };
      };

      netdevs."50-wg0" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
        };

        wireguardConfig = {
          ListenPort = 51820;

          PrivateKeyFile =
            config.sops.secrets."wireguard/serverPrivateKey".path;

          RouteTable = "main";
          FirewallMark = cfg.firewallMarks.outgoing;
        };

        wireguardPeers = lib.map (value: {
          PublicKey = value.userPublicKey;

          AllowedIPs = [
            "${cfg.address.private.ipv4}${value.suffix}/32"
          ]
          ++ (lib.optional (
            cfg.address.private.ipv6 != null
          ) "${cfg.address.private.ipv6}${value.suffix}/128");
        }) (lib.attrValues users);
      };
    };

    networking = {
      nat = {
        enable = true;
        enableIPv6 = true;
        externalInterface = cfg.publicNetworkInterface;
        internalInterfaces = [ "wg0" ];
      };

      firewall = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [
          config.systemd.network.netdevs."50-wg0".wireguardConfig.ListenPort
          53
        ];
      };
    };

    services.unbound = {
      enable = true;
      settings = {
        server = {
          interface = [
            "${cfg.address.private.ipv4}1"
          ]
          ++ (lib.optional (
            cfg.address.private.ipv6 != null
          ) "${cfg.address.private.ipv6}1");
          access-control = [
            "${cfg.address.private.ipv4}0/24 allow"
          ]
          ++ (lib.optional (
            cfg.address.private.ipv6 != null
          ) "${cfg.address.private.ipv6}0/64 allow");
        };
      };
    };
  };
}
