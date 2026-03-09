{
  pkgs,
  lib,
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
      inherit (conf) publicKey;
      allowedIPs = [
        "${wireconf.address.ipv6}${conf.suffix}/128"
        "${wireconf.address.ipv4}${conf.suffix}/32"
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
      internalInterfaces = [
        "wg0"
      ];
    };

    firewall.allowedUDPPorts = [
      config.networking.wg-quick.interfaces.wg0.listenPort
    ];

    wg-quick.interfaces = {
      wg0 = {
        address = [
          "${wireconf.address.ipv6}1/64"
          "${wireconf.address.ipv4}1/32"
        ];

        listenPort = 51820;

        privateKeyFile = config.sops.secrets."wireguard/privateKey".path;

        postUp = ''
          ${lib.getExe pkgs.iptables} -A FORWARD -i wg0 -j ACCEPT
          ${lib.getExe pkgs.iptables} -t nat -A POSTROUTING -s ${wireconf.address.ipv4}1/24 -o ${wireconf.publicNetworkInterface} -j MASQUERADE
          ${pkgs.iptables}/bin/ip6tables -A FORWARD -i wg0 -j ACCEPT
          ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s ${wireconf.address.ipv6}1/64 -o ${wireconf.publicNetworkInterface} -j MASQUERADE
        '';

        preDown = ''
          ${lib.getExe pkgs.iptables} -D FORWARD -i wg0 -j ACCEPT
          ${lib.getExe pkgs.iptables} -t nat -D POSTROUTING -s ${wireconf.address.ipv4}1/24 -o ${wireconf.publicNetworkInterface} -j MASQUERADE
          ${pkgs.iptables}/bin/ip6tables -D FORWARD -i wg0 -j ACCEPT
          ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -s ${wireconf.address.ipv6}1/64 -o ${wireconf.publicNetworkInterface} -j MASQUERADE
        '';

        peers = genPeers (clib.nixFilesRec ./_assets/users);
      };
    };
  };
}
