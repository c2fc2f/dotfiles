{
  config,
  rootDomain,
  username,
  ...
}:
let
  name = "immich";

  cfg = config.services.${name};
  fullDomain = "photo.${rootDomain}";

  inherit (config.services.kanidm.server.settings) origin;
in
{
  services.${name} = {
    enable = true;

    host = "127.0.0.39";
    port = 2283;

    settings = {
      newVersionCheck.enabled = false;

      server.externalDomain = "https://${fullDomain}";

      passwordLogin.enabled = false;

      oauth = {
        enabled = true;

        issuerUrl = "${origin}/oauth2/openid/${name}";
        clientId = name;
        clientSecret._secret =
          config.sops.secrets."${name}/client/secret".path;

        scope = "openid profile email";
        buttonText = "Log in SSO";

        autoRegister = true;
        autoLaunch = true;

        signingAlgorithm = "ES256";
        tokenEndpointAuthMethod = "client_secret_post";

        storageLabelClaim = "preferred_username";

        mobileOverrideEnabled = true;
        mobileRedirectUri = "https://${fullDomain}/api/oauth/mobile-redirect";

        roleClaim = "${name}_role";
      };

      notifications = {
        smtp = {
          enabled = true;

          from = "photo@${rootDomain}";
          replyTo = "noreply@${rootDomain}";

          transport = {
            host = "127.0.0.1";
            port = 25;

            ignoreCert = true;
          };
        };
      };
    };
  };

  services.kanidm.provision = {
    enable = true;

    groups = {
      photo-users = {
        members = [ "photo-admins" ];
        overwriteMembers = false;
      };
      photo-admins = {
        members = [ username ];
        overwriteMembers = false;
      };
    };

    systems.oauth2.${name} = {
      displayName = name;
      originUrl = [
        "https://${fullDomain}/auth/login"
        "https://${fullDomain}/user-settings"
        "https://${fullDomain}/api/oauth/mobile-redirect"
      ];
      originLanding = "https://${fullDomain}/";
      basicSecretFile = config.sops.secrets."${name}/client/secret".path;

      preferShortUsername = true;

      scopeMaps = {
        photo-users = [
          "openid"
          "profile"
          "email"
        ];
      };

      claimMaps."${name}_role" = {
        joinType = "csv";
        valuesByGroup.photo-admins = [ "admin" ];
      };
    };
  };

  custom.services.haproxy = {
    backends = [
      {
        inherit name;
        mode = "http";
        extraConfig = ''
          timeout connect 10s
          timeout server 10m
          timeout tunnel 1h
        '';
        servers = [
          {
            name = "server1";
            addr = "${cfg.host}:${toString cfg.port}";
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
