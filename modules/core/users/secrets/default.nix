{
  sops.secrets."hashedPassword" = {
    sopsFile = ./hashedPassword.yaml;
  };
}
