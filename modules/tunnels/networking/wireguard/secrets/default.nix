{
  lib,
  config,
  hostName,
  ...
}:
let
  secret = {
    sopsFile = ./${hostName}.yaml;

    mode = "640";
    owner = "systemd-network";
    group = "systemd-network";
  };
in
{
  custom.secrets.${hostName}.enable = true;

  sops.secrets = {
    "wireguard/userPrivateKey" = lib.mkIf (
      config.custom.vpn.users ? ${hostName}
    ) secret;
    "wireguard/serverPrivateKey" = lib.mkIf (
      config.custom.vpn.servers ? ${hostName}
    ) secret;
  };
}
