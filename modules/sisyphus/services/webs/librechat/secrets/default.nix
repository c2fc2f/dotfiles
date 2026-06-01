{
  custom.secrets.sisyphus.enable = true;

  sops.secrets = {
    "librechat/client/secret".sopsFile = ./secrets.yaml;
    "librechat/session/secret".sopsFile = ./secrets.yaml;
    "librechat/jwt/secret".sopsFile = ./secrets.yaml;
    "librechat/jwt/refresh/secret".sopsFile = ./secrets.yaml;
    "librechat/creds/key".sopsFile = ./secrets.yaml;
    "librechat/creds/iv".sopsFile = ./secrets.yaml;
  };
}
