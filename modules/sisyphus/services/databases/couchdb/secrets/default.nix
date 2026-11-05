{
  custom.secrets.sisyphus.enable = true;

  sops.secrets."couchdb/admin/password".sopsFile = ./secrets.yaml;
}
