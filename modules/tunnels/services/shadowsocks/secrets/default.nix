{
  custom.secrets.tunnels.enable = true;

  sops.secrets = {
    "shadowsocks/password" = {
      sopsFile = ./secrets.yaml;
    };
  };
}
