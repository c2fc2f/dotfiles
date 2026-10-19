{
  config,
  rootDomain,
  username,
  ...
}:
let
  name = "vaultwarden";

  fullDomain = "pass.${rootDomain}";

  inherit (config.services.kanidm.server.settings) origin;
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
      SMTP_FROM = "${name}@${rootDomain}";
      SMTP_FROM_NAME = "Vaultwarden server";

      SSO_ENABLED = true;
      SSO_ONLY = false;
      SSO_AUTHORITY = "${origin}/oauth2/openid/${name}";
      SSO_SCOPES = "openid profile email";
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

  services.kanidm.provision = {
    enable = true;

    groups = {
      vault-users = {
        members = [ username ];
        overwriteMembers = false;
      };
    };

    systems.oauth2.${name} = {
      displayName = name;
      originUrl = "https://${fullDomain}/";
      originLanding = "https://${fullDomain}/identity/connect/oidc-signin";
      basicSecretFile =
        config.sops.secrets."vaultwarden/client/secret".path;

      scopeMaps = {
        vault-users = [
          "openid"
          "profile"
          "email"
        ];
      };
    };
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
