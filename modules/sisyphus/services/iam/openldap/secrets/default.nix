{ config, username, ... }:
let
  secret =
    let
      inherit (config.services.openldap) user group;
    in
    {
      sopsFile = ./secrets.yaml;

      owner = user;
      inherit group;

      mode = "0440";
    };
in
{
  custom.secrets.sisyphus.enable = true;

  sops.secrets = {
    "openldap/${username}/password" = secret;
    "openldap/readonly/password" = secret;
  };
}
