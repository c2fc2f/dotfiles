{
  custom.secrets.core.enable = true;

  sops.secrets."hashedPassword" = {
    neededForUsers = true;

    sopsFile = ./hashedPassword.yaml;
  };
}
