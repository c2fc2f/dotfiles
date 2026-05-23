{ config, mainDomain, ... }:
let
  domain = "pass.${mainDomain}";
in
{
  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://${domain}";
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";
      SMTP_HOST = "127.0.0.1";
      SMTP_PORT = 25;
      SMTP_SSL = false;
      SMTP_FROM = "vaultwarden@${mainDomain}";
      SMTP_FROM_NAME = "Vaultwarden server";
    };
    environmentFile = config.sops.templates."vaultwarden.env".path;
  };

  sops.templates."vaultwarden.env" = {
    content = ''
      ADMIN_TOKEN="${config.sops.placeholder."vaultwarden/admin/token"}"
    '';
  };

  custom.services.haproxy = {
    backends = [
      {
        name = "vaultwarden";
        mode = "http";
        servers =
          let
            server = config.services.vaultwarden.config;
          in
          [
            {
              name = "server1";
              addr = "${server.ROCKET_ADDRESS}:${toString server.ROCKET_PORT}";
              check = true;
            }
          ];
      }
    ];

    maps = {
      url = [
        {
          url = domain;
          backend = "vaultwarden";
        }
      ];
    };
  };
}
