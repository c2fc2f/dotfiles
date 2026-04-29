{
  config,
  hostName,
  clib,
  ...
}:
let
  wireconf = import ./_assets/servers/${hostName}.nix;

  genPeers = builtins.map (
    file:
    let
      conf = import file;
    in
    {
      PublicKey = conf.publicKey;

      AllowedIPs = [
        "${wireconf.address.private.ipv6}${conf.suffix}/128"
        "${wireconf.address.private.ipv4}${conf.suffix}/32"
      ];
    }
  );
in
{
  networking = {
    nat = {
      enable = true;
      enableIPv6 = true;
      externalInterface = wireconf.publicNetworkInterface;
      internalInterfaces = [ "wg0" ];
    };

    firewall.allowedUDPPorts = [ 51820 ];
  };

  systemd.network = {

    networks."50-wg0" = {
      matchConfig.Name = "wg0";

      address = [
        "${wireconf.address.private.ipv6}1/64"
        "${wireconf.address.private.ipv4}1/32"
      ];

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

        PrivateKeyFile = config.sops.secrets."wireguard/privateKey".path;

        RouteTable = "main";
        FirewallMark = 42;
      };

      wireguardPeers = genPeers (clib.nixFilesRec ./_assets/users);
    };
  };
}
