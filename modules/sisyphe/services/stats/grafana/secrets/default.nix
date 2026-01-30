{
  custom.secrets.sisyphe.enable = true;

  sops.secrets."grafana/client/secret" = {
    sopsFile = ./secrets.yaml;

    owner = "grafana";
  };
}
