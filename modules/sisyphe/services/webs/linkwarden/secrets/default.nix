{
  config,
  ...
}:

{
  custom.secrets.sisyphe.enable = true;

  sops.secrets = {
    "linkwarden/nextauth/secret" = {
      sopsFile = ./secrets.yaml;

      owner = config.services.linkwarden.user;
      inherit (config.services.linkwarden) group;
    };
    "linkwarden/keycloak/issuer" = {
      sopsFile = ./secrets.yaml;

      owner = config.services.linkwarden.user;
      inherit (config.services.linkwarden) group;
    };
    "linkwarden/keycloak/client/id" = {
      sopsFile = ./secrets.yaml;

      owner = config.services.linkwarden.user;
      inherit (config.services.linkwarden) group;
    };
    "linkwarden/keycloak/client/secret" = {
      sopsFile = ./secrets.yaml;

      owner = config.services.linkwarden.user;
      inherit (config.services.linkwarden) group;
    };
  };

}
