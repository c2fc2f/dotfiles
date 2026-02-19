{
  custom.secrets.sisyphe.enable = true;

  sops.secrets = {
    "grafana/client/secret" = {
      sopsFile = ./secrets.yaml;

      owner = "grafana";
    };
    "grafana/security/secret_key" = {
      sopsFile = ./secrets.yaml;

      owner = "grafana";
    };
  };
}
