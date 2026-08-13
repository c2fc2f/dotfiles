{
  rootDomain,
  config,
  pkgs,
  ...
}:
let
  name = "ocis";
  cfg = config.services.${name};
  fullDomain = "drive.${rootDomain}";

  inherit (config.custom.services.authelia) mainInstance domain;

  proxyYaml = (pkgs.formats.yaml { }).generate "${name}-proxy.yaml" {
    role_assignment = {
      driver = "oidc";
      oidc_role_mapper = {
        role_claim = "groups";
        role_mapping = [
          {
            role_name = "admin";
            claim_value = "admins";
          }
          {
            role_name = "user";
            claim_value = "owncloud";
          }
          {
            role_name = "guest";
            claim_value = ".*";
          }
        ];
      };
    };
  };
in
{
  services.${name} = {
    enable = true;

    address = "127.0.0.92";
    port = 9200;

    url = "https://${fullDomain}";

    configDir = "${cfg.stateDir}/config";

    environment = {
      OCIS_INSECURE = "true";
      PROXY_TLS = "false";

      WEB_OIDC_CLIENT_ID = name;

      PROXY_OIDC_ISSUER = "https://${domain}";
      PROXY_OIDC_REWRITE_WELLKNOWN = "true";
      PROXY_OIDC_ACCESS_TOKEN_VERIFY_METHOD = "none";
      PROXY_OIDC_SKIP_USER_INFO = "false";

      PROXY_AUTOPROVISION_ACCOUNTS = "true";
      PROXY_AUTOPROVISION_CLAIM_USERNAME = "preferred_username";
      PROXY_AUTOPROVISION_CLAIM_EMAIL = "email";
      PROXY_AUTOPROVISION_CLAIM_DISPLAYNAME = "name";
      PROXY_AUTOPROVISION_CLAIM_GROUPS = "groups";

      PROXY_ROLE_ASSIGNMENT_DRIVER = "oidc";
    };

    environmentFile = config.sops.templates."${name}.env".path;
  };

  sops.templates."${name}.env" = {
    content = ''
      OCIS_JWT_SECRET=${config.sops.placeholder."owncloud/jwt_secret"}
      OCIS_MACHINE_AUTH_API_KEY=${
        config.sops.placeholder."owncloud/machine_auth_api_key"
      }
      OCIS_TRANSFER_SECRET=${
        config.sops.placeholder."owncloud/transfer_secret"
      }

      OCIS_SYSTEM_USER_ID=${
        config.sops.placeholder."owncloud/system_user/id"
      }
      OCIS_SYSTEM_USER_API_KEY=${
        config.sops.placeholder."owncloud/system_user/api_key"
      }
    '';
  };

  systemd.tmpfiles.rules = [
    "d ${cfg.configDir} 0700 ${cfg.user} ${cfg.group} -"
    "L+ ${cfg.configDir}/proxy.yaml - - - - ${proxyYaml}"
  ];

  services.authelia.instances.${mainInstance}.settings.identity_providers =
    {
      oidc = {
        clients = [
          {
            client_id = name;
            client_name = "ownCloud Infinite Scale";
            public = true;
            require_pkce = true;
            pkce_challenge_method = "S256";
            scopes = [
              "openid"
              "offline_access"
              "groups"
              "profile"
              "email"
            ];
            redirect_uris = [
              "https://${fullDomain}/"
              "https://${fullDomain}/oidc-callback.html"
              "https://${fullDomain}/oidc-silent-redirect.html"
              "https://${fullDomain}/apps/openidconnect/redirect"
            ];
            response_types = [ "code" ];
            grant_types = [
              "authorization_code"
              "refresh_token"
            ];
            access_token_signed_response_alg = "none";
            userinfo_signed_response_alg = "none";
            token_endpoint_auth_method = "none";
          }
          {
            client_id = "xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69";
            client_name = "ownCloud Infinite Scale (Desktop Client)";
            client_secret = "UBntmLjC2yYCeHwsyj73Uwo9TAaecAetRwMw0xYcvNL9yRdLSUi0hUAHfvCHFeFh";
            public = false;
            require_pkce = true;
            pkce_challenge_method = "S256";
            scopes = [
              "openid"
              "offline_access"
              "groups"
              "profile"
              "email"
            ];
            redirect_uris = [
              "http://127.0.0.1"
              "http://localhost"
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
          {
            client_id = "e4rAsNUSIUs0lF4nbv9FmCeUkTlV9GdgTLDH1b5uie7syb90SzEVrbN7HIpmWJeD";
            client_name = "ownCloud Infinite Scale (Android)";
            client_secret = "dInFYGV33xKzhbRmpqQltYNdfLdJIfJ9L5ISoKhNoT9qZftpdWSP71VrpGR9pmoD";
            public = false;
            require_pkce = true;
            pkce_challenge_method = "S256";
            redirect_uris = [ "oc://android.owncloud.com" ];
            scopes = [
              "openid"
              "offline_access"
              "groups"
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
          {
            client_id = "mxd5OQDk6es5LzOzRvidJNfXLUZS2oN3oUFeXPP8LpPrhx3UroJFduGEYIBOxkY1";
            client_name = "ownCloud Infinite Scale (iOS)";
            client_secret = "KFeFWWEZO9TkisIQzR3fo7hfiMXlOpaqP8CFuTbSHzV1TUuGECglPxpiVKJfOXIx";
            public = false;
            require_pkce = true;
            pkce_challenge_method = "S256";
            redirect_uris = [
              "oc://ios.owncloud.com"
              "oc.ios://ios.owncloud.com"
            ];
            scopes = [
              "openid"
              "offline_access"
              "groups"
              "profile"
              "email"
            ];
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
    };

  custom.services.haproxy = {
    backends = [
      {
        inherit name;
        mode = "http";
        servers = [
          {
            name = "server1";
            addr = "${cfg.address}:${toString cfg.port}";
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
