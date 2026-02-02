{
  hostName,
  ...
}:

{
  custom.secrets.${hostName}.enable = true;

  sops.secrets."wireguard/privateKey" = {
    sopsFile = ./${hostName}.yaml;
  };
}
