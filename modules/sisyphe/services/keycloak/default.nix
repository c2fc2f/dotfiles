{
  pkgs,
  config,
  mainDomain,
  ...
}:
let
  domain = "auth.${mainDomain}";
in
{
  services.keycloak = {
    enable = true;

    inherit (pkgs.callPackage ./_plugins { }) plugins;

    initialAdminPassword = "password";

    database.passwordFile = config.sops.secrets."keycloak/passwordDB".path;

    settings = {
      hostname = "https://${domain}";
      http-host = "127.0.0.38";
      http-port = 38080;
      http-enabled = true;
      https-enabled = false;
      proxy-headers = "xforwarded";

      health-enabled = true;

      log-console-level = "debug";
    };
  };

  systemd.services.keycloak.environment = {
    TAILCLOAKIFY_HEADER_LOGO_URL = "https://sagbot.com/sagbot_banner.png";
    TAILCLOAKIFY_FAVICON_URL = "https://sagbot.com/uwulock.png";
  };

  custom.services.haproxy = {
    backends = [
      {
        name = "keycloak";
        mode = "http";
        servers =
          let
            inherit (config.services.keycloak.settings) http-host http-port;
          in
          [

            {
              name = "server1";
              addr = "${http-host}:${toString http-port}";
              check = true;
            }
          ];
      }
    ];

    maps = {
      url = [
        {
          url = domain;
          backend = "keycloak";
        }
      ];
    };
  };
}
