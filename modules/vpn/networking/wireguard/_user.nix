{
  config,
  hostName,
  clib,
  mainDomain,
  ...
}:
let
  wireconf = import ./_assets/users/${hostName}.nix;

  nameWithoutExt =
    path:
    builtins.head (
      builtins.match "(.*)\\.nix" (builtins.baseNameOf (toString path))
    );

  genNetworks =
    files:
    builtins.listToAttrs (
      builtins.map (
        file:
        let
          conf = import file;
          name = nameWithoutExt file;
        in
        {
          name = "50-${name}";
          value = {
            matchConfig.Name = "wg-${name}";

            linkConfig = {
              ActivationPolicy = "down";
            };

            address = [
              "${conf.address.private.ipv6}${wireconf.suffix}/128"
              "${conf.address.private.ipv4}${wireconf.suffix}/32"
            ];

            domains = [ "~." ];
            dns = [
              "1.1.1.1"
              "1.0.0.1"
              "2606:4700:4700::1111"
              "2606:4700:4700::1001"
            ];
            networkConfig = {
              DNSDefaultRoute = true;
            };

            routingPolicyRules = [
              {
                Family = "both";

                InvertRule = true;
                FirewallMark = 42;

                Table = 1000;

                Priority = 10;
              }
              {
                To = "${conf.address.public.ipv6}/128";
                Priority = 5;
              }
              {
                To = "${conf.address.public.ipv4}/32";
                Priority = 5;
              }
            ];
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
          name = nameWithoutExt file;
        in
        {
          name = "50-${name}";
          value = {
            netdevConfig = {
              Kind = "wireguard";
              Name = "wg-${name}";
            };

            wireguardConfig = {
              ListenPort = 51820;

              PrivateKeyFile = config.sops.secrets."wireguard/privateKey".path;

              RouteTable = "main";
              FirewallMark = 42;
            };

            wireguardPeers = [
              {
                PublicKey = conf.publicKey;
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
    allowedUDPPorts = [ 51820 ];
  };

  systemd.network = {
    enable = true;

    networks = genNetworks (clib.nixFilesRec ./_assets/servers);
    netdevs = genNetdevs (clib.nixFilesRec ./_assets/servers);
  };
}
