{
  config,
  hostName,
  lib,
  clib,
  mainDomain,
  ...
}:
let
  wireconf = import ./_assets/users/${hostName}.nix;

  serversConf = builtins.filter (
    file: (clib.nameWithoutExt file) != hostName
  ) (clib.nixFilesRec ./_assets/servers);

  genNetworks =
    files:
    builtins.listToAttrs (
      builtins.map (
        file:
        let
          conf = import file;
          name = clib.nameWithoutExt file;
        in
        {
          name = "50-${name}";
          value = {
            matchConfig.Name = "wg-${name}";

            linkConfig = {
              ActivationPolicy = if wireconf.alwaysUp then "always-up" else "down";
            };

            address = [
              "${conf.address.private.ipv6}${wireconf.suffix}/128"
              "${conf.address.private.ipv4}${wireconf.suffix}/32"
            ];

            domains = lib.mkIf wireconf.routeEverything [ "~." ];
            dns = lib.mkIf wireconf.routeEverything [
              "${conf.address.private.ipv6}1"
              "${conf.address.private.ipv4}1"
            ];

            networkConfig = {
              DefaultRouteOnDevice = wireconf.routeEverything;
              DNSDefaultRoute = wireconf.routeEverything;
            };

            routingPolicyRules = [
              {
                To = "${conf.address.public.ipv6}/128";
                Priority = 5;
              }
              {
                To = "${conf.address.public.ipv4}/32";
                Priority = 5;
              }
              {
                To = "${conf.address.private.ipv4}0/24";
                Table = 1000;
                Priority = 10;
              }
              {
                To = "${conf.address.private.ipv6}/64";
                Table = 1000;
                Priority = 10;
              }
            ]
            ++ (
              if wireconf.routeEverything then
                [
                  {
                    Family = "both";
                    InvertRule = true;
                    FirewallMark = 42;
                    Table = 1000;
                    Priority = 10;
                  }
                ]
              else
                [
                  {
                    Family = "both";
                    FirewallMark = 33;
                    Table = 1000;
                    Priority = 15;
                  }
                ]
            );
          };
        }
      ) files
    );

  genNetdevs =
    files:
    builtins.listToAttrs (
      builtins.map (
        file:
        let
          conf = import file;
          name = clib.nameWithoutExt file;
        in
        {
          name = "50-${name}";
          value = {
            netdevConfig = {
              Kind = "wireguard";
              Name = "wg-${name}";
            };

            wireguardConfig = {
              ListenPort = 43282;

              PrivateKeyFile = config.sops.secrets."wireguard/userPrivateKey".path;

              RouteTable = "main";
              FirewallMark = 42;
            };

            wireguardPeers = [
              {
                PublicKey = conf.serverPublicKey;
                AllowedIPs = [
                  "::/0"
                  "0.0.0.0/0"
                ];
                Endpoint = "${name}.${mainDomain}:51820";
                RouteTable = 1000;
              }
            ];
          };
        }
      ) files
    );
in

{
  networking.firewall = {
    checkReversePath = "loose";
    allowedUDPPorts = [
      51820
      43282
    ];
  };

  systemd.network = {
    enable = true;

    networks = genNetworks serversConf;
    netdevs = genNetdevs serversConf;
  };
}
