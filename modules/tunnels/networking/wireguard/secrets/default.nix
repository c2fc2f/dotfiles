{ hostName, ... }:

{
  custom.secrets.${hostName}.enable = true;

  sops.secrets."wireguard/privateKey" = {
    sopsFile = ./${hostName}.yaml;

    mode = "640";
    owner = "systemd-network";
    group = "systemd-network";
  };
}
