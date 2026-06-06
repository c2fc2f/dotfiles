{ lib, hostName, ... }:
let
  isServer = builtins.pathExists ../_assets/servers/${hostName}.nix;
  isUser = builtins.pathExists ../_assets/users/${hostName}.nix;

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
    "wireguard/userPrivateKey" = lib.mkIf isUser secret;
    "wireguard/serverPrivateKey" = lib.mkIf isServer secret;
  };
}
