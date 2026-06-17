{
  lib,
  config,
  mainDomain,
  ...
}:
let
  name = "matrix-tuwunel";
  cfg = config.services.${name};

  fullDomain = "matrix.${mainDomain}";
  inherit (config.custom.services.authelia) mainInstance domain;
in
{
  services.${name} = {
    enable = true;

    settings = {
      global = {
        address = [ "127.0.0.67" ];
        port = [ 6167 ];

        server_name = mainDomain;

        allow_encryption = true;
        allow_federation = true;
        allow_registration = false;

        well_known = {
          client = "https://${fullDomain}";
          server = "${fullDomain}:443";
        };
      };
    };

    extraEnvironment = {
      CONDUWUIT_CONFIG = config.sops.templates."${name}_oidc.toml".path;
    };
  };

  sops.templates."${name}_oidc.toml" = {
    content = ''
      [[global.identity_provider]]
      id = "${name}"
      brand = "Authelia"
      name = "Authelia"
      client_id = "${name}"
      client_secret = "${config.sops.placeholder."${name}/client/secret"}"
      issuer_url = "https://${domain}"
      callback_url = "https://${fullDomain}/_matrix/client/unstable/login/sso/callback/${name}"
    '';

    owner = cfg.user;
    inherit (cfg) group;
  };

  services.authelia.instances.${mainInstance}.settings.identity_providers =
    {
      oidc = {
        claims_policies.${name}.id_token = [
          "email"
          "name"
          "groups"
          "preferred_username"
        ];

        clients = [
          {
            client_id = name;
            client_name = name;
            client_secret = "$argon2id$v=19$m=65536,t=3,p=4$bPh8rRl7sySGWKo4ZJaX8Q$4N3MUn47BKPAPYCoS/3qK2AEFpEjk61cQx8rdmygK0k";
            claims_policy = name;
            public = false;
            consent_mode = "implicit";
            scopes = [
              "openid"
              "groups"
              "email"
              "profile"
            ];
            redirect_uris = [
              "https://${fullDomain}/_matrix/client/unstable/login/sso/callback/${name}"
            ];
            grant_types = [
              "refresh_token"
              "authorization_code"
            ];
            response_types = [ "code" ];
            response_modes = [ "form_post" ];
            token_endpoint_auth_method = "client_secret_post";
          }
        ];
      };
    };

  custom.services.haproxy = {
    backends = [
      {
        inherit name;
        mode = "http";
        extraConfig = ''
          timeout server 0ms
          timeout connect 0ms
        '';
        servers =
          let
            address = builtins.elemAt cfg.settings.global.address 0;
            port = builtins.elemAt cfg.settings.global.port 0;
          in
          [
            {
              name = "server1";
              addr = "${address}:${toString port}";
              check = true;
            }
          ];
      }
    ];

    maps = {
      url = lib.mkBefore [
        {
          url = fullDomain;
          backend = name;
        }
        {
          url = "${mainDomain}/.well-known/matrix/client";
          backend = name;
        }
        {
          url = "${mainDomain}/.well-known/matrix/server";
          backend = name;
        }
      ];
    };
  };
}
