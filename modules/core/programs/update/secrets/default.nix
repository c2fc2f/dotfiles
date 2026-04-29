{ username, ... }:

{
  sops.secrets."github/token/readonly" = {
    sopsFile = ./secrets.yaml;
    owner = username;
  };
}
