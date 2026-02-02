{
  username,
  ...
}:

{
  custom.secrets.development.enable = true;

  sops.secrets."language-tool/username" = {
    sopsFile = ./secrets.yaml;
    owner = username;
  };
  sops.secrets."language-tool/api-key" = {
    sopsFile = ./secrets.yaml;
    owner = username;
  };
}
