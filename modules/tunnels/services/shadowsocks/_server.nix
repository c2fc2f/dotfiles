{ config, pkgs, ... }:

{
  services.shadowsocks = {
    enable = true;
    package = pkgs.shadowsocks-rust;

    localAddress = "::";

    passwordFile = config.sops.secrets."shadowsocks/password".path;
  };

  networking.firewall =
    let
      inherit (config.services.shadowsocks) port;
    in
    {
      allowedTCPPorts = [ port ];
      allowedUDPPorts = [ port ];
    };
}
