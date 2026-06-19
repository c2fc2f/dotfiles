{
  config,
  hostName,
  lib,
  mainDomain,
  ...
}:
let
  cfg = config.custom.vpn.users.${hostName};
  servers = lib.filterAttrs (
    name: _: name != hostName
  ) config.custom.vpn.servers;
in

{
  config = lib.mkIf (config.custom.vpn.users ? ${hostName}) {
    systemd.network = {
      enable = true;

      networks = lib.mapAttrs' (name: value: {
        name = "50-${name}";
        value = {
          matchConfig.Name = "wg-${name}";

          linkConfig = {
            ActivationPolicy = if cfg.alwaysUp then "always-up" else "down";
          };

          address = [
            "${value.address.private.ipv4}${cfg.suffix}/32"
          ]
          ++ (lib.optional (
            value.address.private.ipv6 != null
          ) "${value.address.private.ipv6}${cfg.suffix}/128");

          domains = lib.mkIf cfg.routeEverything [ "~." ];
          dns = lib.mkIf cfg.routeEverything (
            [ "${value.address.private.ipv4}1" ]
            ++ (lib.optional (
              value.address.private.ipv6 != null
            ) "${value.address.private.ipv6}1")
          );

          networkConfig = {
            DefaultRouteOnDevice = cfg.routeEverything;
            DNSDefaultRoute = cfg.routeEverything;
          };

          routingPolicyRules = [
            {
              To = "${value.address.public.ipv4}/32";
              Priority = 5;
            }
            {
              To = "${value.address.private.ipv4}0/24";
              Table = value.RouteTable;
              Priority = 10;
            }
            {
              From = "${value.address.private.ipv4}${cfg.suffix}/32";
              Table = value.RouteTable;
            }
            {
              Family = "both";
              FirewallMark = value.firewallMarks.force;
              Table = value.RouteTable;
              Priority = 15;
            }
          ]
          ++ (lib.optional (value.address.public.ipv6 != null) {
            To = "${value.address.public.ipv6}/128";
            Priority = 5;
          })
          ++ (lib.optional (value.address.private.ipv6 != null) {
            To = "${value.address.private.ipv6}/64";
            Table = value.RouteTable;
            Priority = 10;
          })
          ++ (lib.optional (value.address.private.ipv6 != null) {
            From = "${value.address.private.ipv6}${cfg.suffix}/128";
            Table = value.RouteTable;
          })
          ++ (lib.optional cfg.routeEverything {
            Family = "both";
            InvertRule = true;
            Table = value.RouteTable;
            Priority = 10;
            FirewallMark = value.firewallMarks.outgoing;
          });
        };
      }) servers;

      netdevs = lib.mapAttrs' (name: value: {
        name = "50-${name}";
        value = {
          netdevConfig = {
            Kind = "wireguard";
            Name = "wg-${name}";
          };

          wireguardConfig = {
            PrivateKeyFile = config.sops.secrets."wireguard/userPrivateKey".path;

            RouteTable = "main";
            FirewallMark = value.firewallMarks.outgoing;
          };

          wireguardPeers = [
            {
              PublicKey = value.serverPublicKey;
              AllowedIPs = [
                "0.0.0.0/0"
              ]
              ++ (lib.optional (value.address.private.ipv6 != null) "::/0");
              Endpoint = "${name}.${mainDomain}:51820";
              inherit (value) RouteTable;
            }
          ];
        };
      }) servers;
    };

    networking.firewall = {
      checkReversePath = "loose";
      allowedUDPPorts = [
        51820
        43282
      ];
    };
  };
}
