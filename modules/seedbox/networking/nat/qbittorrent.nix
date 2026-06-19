{
  lib,
  config,
  hostName,
  builder,
  ...
}:
let
  cfg = config.custom.vpn.servers.${hostName};
  inherit (config.custom.vpn.users.${builder}) suffix;
in
{
  networking.nat = {
    enable = true;

    forwardPorts = [
      {
        sourcePort = 51413;
        proto = "tcp";
        destination = "${cfg.address.private.ipv4}${suffix}:51413";
      }
      {
        sourcePort = 51413;
        proto = "udp";
        destination = "${cfg.address.private.ipv4}${suffix}:51413";
      }
    ]
    ++ (lib.optionals (cfg.address.private.ipv6 != null) [
      {
        sourcePort = 51413;
        proto = "tcp";
        destination = "[${cfg.address.private.ipv6}${suffix}]:51413";
      }
      {
        sourcePort = 51413;
        proto = "udp";
        destination = "[${cfg.address.private.ipv6}${suffix}]:51413";
      }
    ]);
  };

  networking.firewall = {
    allowedTCPPorts = [ 51413 ];
    allowedUDPPorts = [ 51413 ];
  };
}
