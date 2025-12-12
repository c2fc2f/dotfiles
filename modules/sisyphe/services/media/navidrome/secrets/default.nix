{
  sops.secrets = {
    "navidrome/env" = {
      sopsFile = ./environement;
      format = "binary";
    };
  };
}
