{
  custom.secrets.sisyphe.enable = true;

  sops.secrets = {
    "keycloak/passwordDB" = {
      sopsFile = ./password;
      format = "binary";
    };
  };
}
