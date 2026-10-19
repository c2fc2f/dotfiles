{
  lib,
  config,
  rootDomain,
  username,
  ...
}:
let
  name = "matrix-tuwunel";
  cfg = config.services.${name};

  fullDomain = "matrix.${rootDomain}";
  inherit (config.services.kanidm.server.settings) origin;
in
{
  services.${name} = {
    enable = true;

    settings = {
      global = {
        address = [ "127.0.0.67" ];
        port = [ 6167 ];

        server_name = toString rootDomain;

        allow_encryption = true;
        allow_federation = true;
        allow_registration = false;

        well_known = {
          client = "https://${fullDomain}";
          server = "${fullDomain}:443";
        };

        appservice_dir = "/etc/${name}/appservices/";
      };
    };

    extraEnvironment = {
      CONDUWUIT_CONFIG = config.sops.templates."${name}_oidc.toml".path;
    };
  };

  systemd.tmpfiles.rules = [
    "d ${cfg.settings.global.appservice_dir} 0755 root root - -"
  ];

  sops.templates."${name}_oidc.toml" = {
    content = ''
      [[global.identity_provider]]
      id = "${name}"
      brand = "SSO"
      name = "SSO"
      client_id = "${name}"
      client_secret = "${config.sops.placeholder."${name}/client/secret"}"
      issuer_url = "${origin}/oauth2/openid/${name}"
      callback_url = "https://${fullDomain}/_matrix/client/unstable/login/sso/callback/${name}"

      trusted = true
      userid_claims = ["preferred_username"]
      unique_id_fallbacks = false
    '';

    owner = cfg.user;
    inherit (cfg) group;
  };

  services.kanidm.provision = {
    enable = true;

    groups = {
      matrix-users = {
        members = [ username ];
        overwriteMembers = false;
      };
    };

    systems.oauth2.${name} = {
      displayName = name;
      originUrl = "https://${fullDomain}/";
      originLanding = "https://${fullDomain}/_matrix/client/unstable/login/sso/callback/${name}";
      basicSecretFile = config.sops.secrets."${name}/client/secret".path;

      preferShortUsername = true;

      scopeMaps = {
        matrix-users = [
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
          url = "${rootDomain}/.well-known/matrix/client";
          backend = name;
        }
        {
          url = "${rootDomain}/.well-known/matrix/server";
          backend = name;
        }
      ];
    };
  };
}
