{ config, mainDomain, ... }:
let
  name = "vaultwarden";

  fullDomain = "pass.${mainDomain}";

  inherit (config.custom.services.authelia) mainInstance;
in
{
  services.${name} = {
    enable = true;
    config = {
      DOMAIN = "https://${fullDomain}";
      SIGNUPS_ALLOWED = false;

      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";

      SMTP_HOST = "127.0.0.1";
      SMTP_PORT = 25;
      SMTP_SSL = false;
      SMTP_FROM = "${name}@${mainDomain}";
      SMTP_FROM_NAME = "Vaultwarden server";

      SSO_ENABLED = true;
      SSO_ONLY = false;
      SSO_AUTHORITY = "https://${config.custom.services.authelia.domain}";
      SSO_SCOPES = "profile email offline_access";
      SSO_PKCE = true;
      SSO_CLIENT_ID = name;
    };
    environmentFile = config.sops.templates."vaultwarden.env".path;
  };

  sops.templates."vaultwarden.env" = {
    content = ''
      ADMIN_TOKEN="${config.sops.placeholder."vaultwarden/admin/token"}"
      SSO_CLIENT_SECRET="${
        config.sops.placeholder."vaultwarden/client/secret"
      }"
    '';
  };

  services.authelia.instances.${mainInstance}.settings.identity_providers =
    {
      oidc.clients = [
        {
          client_id = name;
          client_name = name;
          client_secret = "$argon2id$v=19$m=65536,t=3,p=4$FcI2x2AR52vHaw1Mix629g$WJkZJpeIWQoh6h8LLk+F2KQ/5QWrF88SxbLI9S+EtQo";
          public = false;
          require_pkce = true;
          pkce_challenge_method = "S256";
          redirect_uris = [
            "https://${fullDomain}/identity/connect/oidc-signin"
          ];
          scopes = [
            "openid"
            "offline_access"
            "profile"
            "email"
          ];
          response_types = [ "code" ];
          grant_types = [
            "authorization_code"
            "refresh_token"
          ];
          access_token_signed_response_alg = "none";
          userinfo_signed_response_alg = "none";
          token_endpoint_auth_method = "client_secret_basic";
        }
      ];
    };

  custom.services.haproxy = {
    backends = [
      {
        inherit name;
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
          url = fullDomain;
          backend = name;
        }
      ];
    };
  };
}
