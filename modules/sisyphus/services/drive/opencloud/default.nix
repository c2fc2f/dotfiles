{
  pkgs,
  config,
  rootDomain,
  username,
  ...
}:
let
  fullDomain = "drive.${rootDomain}";

  name = "opencloud";
  cfg = config.services.${name};

  join = builtins.concatStringsSep " ";

  scopes = [
    "openid"
    "profile"
    "email"
    "groups"
  ];
  # Kanidm don't support offline_access
  fullScopes = scopes; # ++ [ "offline_access" ];

  inherit (config.services.kanidm.server.settings) domain origin;
in
{
  services.${name} = {
    enable = true;

    package = pkgs.opencloud;

    address = "127.0.0.92";
    port = 9200;

    url = "https://${fullDomain}";

    environment = {
      OC_OIDC_ISSUER = "${origin}/oauth2/openid/${name}";
    };

    settings = {
      runtime.disabled_services = [ "idp" ];

      proxy = {
        http.tls = false;
        auto_provision_accounts = true;
        auto_provision_claims.groups = "groups";
        oidc.rewrite_well_known = true;
        role_assignment = {
          driver = "oidc";
          oidc_role_mapper = {
            role_claim = "groups";
            role_mapping = [
              {
                role_name = "admin";
                claim_value = "opencloud-admins@${domain}";
              }
              {
                role_name = "user";
                claim_value = "opencloud-users@${domain}";
              }
              {
                role_name = "user-light";
                claim_value = "opencloud-guests@${domain}";
              }
            ];
          };
        };

        csp_config_file_location = "/etc/${name}/csp.yaml";
      };

      graph.api = {
        graph_assign_default_user_role = false;
        graph_username_match = "none";
      };

      webfinger = {
        android_client_id = name;
        android_client_scopes = join fullScopes;
        ios_client_id = name;
        ios_client_scopes = join fullScopes;
        desktop_client_id = name;
        desktop_client_scopes = join fullScopes;
        web_client_id = name;
        web_client_scopes = join scopes;
      };

      csp.directives = {
        child-src = [ "'self'" ];
        connect-src = [
          "'self'"
          "blob:"
          "https://raw.githubusercontent.com/opencloud-eu/awesome-apps/"
          "https://update.opencloud.eu/"
          origin
        ];
        default-src = [ "'none'" ];
        font-src = [ "'self'" ];
        frame-ancestors = [ "'self'" ];
        frame-src = [
          "'self'"
          "blob:"
          "https://embed.diagrams.net/"
        ];
        img-src = [
          "'self'"
          "data:"
          "blob:"
          "https://raw.githubusercontent.com/opencloud-eu/awesome-apps/"
        ];
        manifest-src = [ "'self'" ];
        media-src = [ "'self'" ];
        object-src = [
          "'self'"
          "blob:"
        ];
        script-src = [
          "'self'"
          "'unsafe-inline'"
        ];
        style-src = [
          "'self'"
          "'unsafe-inline'"
          "blob:"
        ];
      };
    };
  };

  services.kanidm.provision = {
    enable = true;

    groups = {
      opencloud-guests = {
        overwriteMembers = false;
      };
      opencloud-users = {
        members = [ "opencloud-admins" ];
        overwriteMembers = false;
      };
      opencloud-admins = {
        members = [ username ];
        overwriteMembers = false;
      };
    };

    systems.oauth2.${name} = {
      displayName = name;
      originUrl = [
        "https://${fullDomain}/"
        "https://${fullDomain}/oidc-callback.html"
        "https://${fullDomain}/oidc-silent-redirect.html"

        "oc://android.opencloud.eu"

        "oc://ios.opencloud.eu"

        "http://127.0.0.1"
        "http://localhost"
      ];
      originLanding = "https://${fullDomain}/";

      public = true;

      scopeMaps = {
        opencloud-users = fullScopes;
        opencloud-guests = fullScopes;
      };
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
