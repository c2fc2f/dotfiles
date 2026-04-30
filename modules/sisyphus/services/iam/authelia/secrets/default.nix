{ config, ... }:
let
  secret =
    let
      inherit (config.services.authelia.instances.main) user group;
    in
    {
      sopsFile = ./secrets.yaml;

      owner = user;
      inherit group;
    };
in
{
  custom.secrets.sisyphus.enable = true;

  sops.secrets = {
    "authelia/jwtSecret" = secret;
    "authelia/oidc/hmacSecret" = secret;
    "authelia/oidc/jwks/key" = secret;
    "authelia/session/secret" = secret;
    "authelia/storage/encryptionKey" = secret;
  };
}
