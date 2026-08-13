let
  secret = {
    sopsFile = ./secrets.yaml;
  };
in
{
  custom.secrets.sisyphus.enable = true;

  sops.secrets = {
    "owncloud/jwt_secret" = secret;
    "owncloud/machine_auth_api_key" = secret;
    "owncloud/transfer_secret" = secret;
    "owncloud/system_user/id" = secret;
    "owncloud/system_user/api_key" = secret;
  };
}
