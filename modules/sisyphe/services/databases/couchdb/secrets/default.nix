{
  config,
  ...
}:

{
  custom.secrets.sisyphe.enable = true;

  sops.secrets."couchdb/admin" = {
    sopsFile = ./admin;
    format = "binary";

    owner = config.services.couchdb.user;
  };
}
