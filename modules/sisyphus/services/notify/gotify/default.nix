{
  mainDomain,
  config,
  pkgs,
  ...
}:
let
  name = "gotify";

  fullDomain = "notify.${mainDomain}";

  inherit (config.custom.services.authelia) mainInstance;
in
{
  services.gotify = {
    enable = true;

    package = pkgs.callPackage ./_package { };

    environment = {
      GOTIFY_SERVER_PORT = 8103;
      GOTIFY_SERVER_LISTENADDR = "127.0.0.103";
      GOTIFY_SERVER_SSL_ENABLED = "false";

      GOTIFY_REGISTRATION = "false";
      GOTIFY_DEFAULTUSER_NAME = "admin";

      GOTIFY_OIDC_ENABLED = "true";
      GOTIFY_OIDC_ISSUER = "https://${config.custom.services.authelia.domain}";
      GOTIFY_OIDC_CLIENTID = "gotify";
      GOTIFY_OIDC_REDIRECTURL = "https://${fullDomain}/auth/oidc/callback";
      GOTIFY_OIDC_AUTOREGISTER = "true";
      GOTIFY_OIDC_USERNAMECLAIM = "preferred_username";
    };

    environmentFiles = [ config.sops.templates."gotify.env".path ];
  };

  sops.templates."gotify.env" = {
    content = ''
      GOTIFY_DEFAULTUSER_PASS="${
        config.sops.placeholder."gotify/admin/password"
      }"
      GOTIFY_OIDC_CLIENTSECRET="${
        config.sops.placeholder."gotify/client/secret"
      }"
    '';
  };

  services.authelia.instances.${mainInstance}.settings.identity_providers =
    {
      oidc.clients = [
        {
          client_id = name;
          client_name = name;
          client_secret = "$argon2id$v=19$m=65536,t=3,p=4$TbO2my8ywA9tRjxoHuYXYw$mR0kCkBr+wQi3UOihgc6IZ3IK26eTsyQy3t2XpVlD6A";
          public = false;
          require_pkce = true;
          pkce_challenge_method = "S256";
          consent_mode = "implicit";
          redirect_uris = [
            "https://${fullDomain}/auth/oidc/callback"
            "gotify://oidc/callback"
          ];
          scopes = [
            "openid"
            "profile"
            "email"
          ];
          response_types = [ "code" ];
          grant_types = [ "authorization_code" ];
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
            inherit (config.services.gotify.environment)
              GOTIFY_SERVER_LISTENADDR
              GOTIFY_SERVER_PORT
              ;
          in
          [
            {
              name = "server1";
              addr = "${GOTIFY_SERVER_LISTENADDR}:${toString GOTIFY_SERVER_PORT}";
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
