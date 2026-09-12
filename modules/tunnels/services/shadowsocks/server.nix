{
  config,
  pkgs,
  lib,
  systemInfo,
  hostName,
  ...
}:
let
  isServer = builtins.elem "server" systemInfo.${hostName}.groups;
in
{
  services.shadowsocks = {
    enable = isServer;
    package = pkgs.shadowsocks-rust;

    localAddress = "::";
    port = 8389;

    plugin = lib.getExe pkgs.shadowsocks-v2ray-plugin;
    pluginOpts = "server";

    passwordFile = config.sops.secrets."shadowsocks/password".path;
  };

  networking.firewall =
    let
      inherit (config.services.shadowsocks) port;
    in
    lib.optionalAttrs isServer {
      allowedTCPPorts = [ port ];
      allowedUDPPorts = [ port ];
    };
}
