{
  custom.secrets.sisyphus.enable = true;

  sops.secrets = {
    "cross-seed/apiKey" = {
      sopsFile = ./secrets.yaml;
    };
    "cross-seed/qbittorrent/password" = {
      sopsFile = ./secrets.yaml;
    };
  };
}
