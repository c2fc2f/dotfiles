{
  custom.secrets.core.enable = true;

  sops.secrets."hashedPassword" = {
    sopsFile = ./hashedPassword.yaml;
  };
}
