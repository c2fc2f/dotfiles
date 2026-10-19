let
  secret = {
    sopsFile = ./secrets.yaml;

    owner = "kanidm";
    group = "kanidm";
  };
in
{
  custom.secrets.sisyphus.enable = true;

  sops.secrets = {
    "kanidm/adminPasswordFile" = secret;
    "kanidm/idmAdminPasswordFile" = secret;
  };
}
