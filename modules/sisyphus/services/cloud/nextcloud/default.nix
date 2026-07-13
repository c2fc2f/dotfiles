{
  pkgs,
  config,
  lib,
  rootDomain,
  username,
  ...
}:
let
  name = "nextcloud";

  fullDomain = "cloud.${rootDomain}";

  inherit (config.custom.services.authelia) mainInstance domain;
in
{
  services = {
    ${name} = {
      enable = true;
      package = pkgs.nextcloud33;

      hostName = fullDomain;
      https = true;

      configureRedis = true;
      autoUpdateApps.enable = false;

      maxUploadSize = "1G";

      config = {
        dbtype = "pgsql";

        adminuser = null;
      };

      database.createLocally = true;

      notify_push = {
        enable = true;
        bendDomainToLocalhost = true;
      };

      enableImagemagick = true;
      appstoreEnable = false;

      extraAppsEnable = true;
      extraApps = {
        inherit (config.services.nextcloud.package.packages.apps)
          oidc_login
          calendar
          tasks
          ;
      };

      settings = {
        "allow_user_to_change_display_name" = false;
        "lost_password_link" = "disabled";

        "oidc_login_provider_url" = "https://${domain}";
        "oidc_login_client_id" = name;

        "oidc_login_disable_registration" = false;
        "oidc_login_password_authentication" = false;
        "oidc_login_auto_redirect" = true;
        "oidc_login_end_session_redirect" = false;
        "oidc_login_hide_password_form" = true;
        "oidc_login_use_id_token" = false;
        "oidc_login_attributes" = {
          "id" = "preferred_username";
          "name" = "name";
          "mail" = "email";
          "groups" = "groups";
          "is_admin" = "is_nextcloud_admin";
        };
        "oidc_login_default_group" = "oidc";
        "oidc_login_use_external_storage" = false;

        "oidc_login_scope" = "openid profile email groups nextcloud_userinfo";

        "oidc_login_proxy_ldap" = false;
        "oidc_login_redir_fallback" = false;
        "oidc_login_tls_verify" = true;
        "oidc_create_groups" = false;
        "oidc_login_webdav_enabled" = false;
        "oidc_login_public_key_caching_time" = 86400;
        "oidc_login_min_time_between_jwks_requests" = 10;
        "oidc_login_well_known_caching_time" = 86400;
        "oidc_login_update_avatar" = false;
        "oidc_login_code_challenge_method" = "S256";

        "oidc_login_logout_url" = "https://${domain}/logout";

        "mail_smtpmode" = "sendmail";
        "mail_sendmailmode" = "pipe";
      };

      secretFile = config.sops.templates."${name}-secrets.json".path;
    };

    authelia.instances.${mainInstance}.settings = {
      definitions = {
        user_attributes = {
          is_nextcloud_admin = {
            expression = ''
              ("${name}-admins" in groups) || 
              ("admins" in groups)
            '';
          };
        };
      };

      identity_providers = {
        oidc = {
          claims_policies = {
            nextcloud_userinfo = {
              custom_claims = {
                is_nextcloud_admin = { };
              };
            };
          };

          scopes = {
            nextcloud_userinfo = {
              claims = [ "is_nextcloud_admin" ];
            };
          };

          authorization_policies = {
            "${name}_policies" = {
              default_policy = "deny";
              rules = [
                {
                  policy = "two_factor";
                  subject = [ "group:${name}" ];
                }
              ];
            };
          };

          clients = [
            {
              client_id = name;
              client_name = name;
              client_secret = "$pbkdf2-sha512$310000$LfUmyXEk2Q2etrbY7.y8Ag$HFrEeBcKAqQrhwSqrVGP6bnQc9jVwKVtYXtrKE7j.gso7gTCTrAxVSgLFqeejD1jBg.TNu4vSmG9gNLW.l9cEg";
              authorization_policy = "${name}_policies";
              public = false;
              require_pkce = true;
              pkce_challenge_method = "S256";
              claims_policy = "nextcloud_userinfo";
              consent_mode = "implicit";
              redirect_uris = [ "https://${fullDomain}/apps/oidc_login/oidc" ];
              scopes = [
                "openid"
                "profile"
                "email"
                "groups"
                "nextcloud_userinfo"
              ];
              response_types = [ "code" ];
              grant_types = [ "authorization_code" ];
              access_token_signed_response_alg = "none";
              userinfo_signed_response_alg = "none";
              token_endpoint_auth_method = "client_secret_basic";
            }
          ];
        };
      };
    };

    nginx = {
      enable = true;
      virtualHosts.${config.services.nextcloud.hostName} = {
        listen = [
          {
            addr = "127.0.0.127";
            port = 127;
          }
        ];
        extraConfig = ''
          set_real_ip_from 127.0.0.0/8; 
          real_ip_header X-Forwarded-For;
          real_ip_recursive on;
        '';
      };
    };
  };

  sops.templates."${name}-secrets.json" = {
    content = ''
      {
        "oidc_login_client_secret": "${
          config.sops.placeholder."${name}/client/secret"
        }"
      }
    '';
  };

  systemd.services = {
    nextcloud-notify_push_setup.after = [ "haproxy.service" ];

    nextcloud-custom-config = {
      path = [ config.services.nextcloud.occ ];
      script = ''
        nextcloud-occ theming:config name "${lib.toUpper rootDomain.sld} Cloud"
        nextcloud-occ theming:config url "https://${fullDomain}";

        nextcloud-occ theming:config privacyUrl "https://${rootDomain}/privacy";

        nextcloud-occ theming:config slogan "One must imagine Sisyphus happy";

        nextcloud-occ theming:config disable-user-theming true;
        nextcloud-occ theming:config color "#F6F6F6";
        nextcloud-occ theming:config primary_color "#F6F6F6";
        nextcloud-occ theming:config background_color "#191919";
        nextcloud-occ theming:config logo ${./assets/logo.svg}
      '';
      after = [
        "nextcloud-setup.service"
        "haproxy.service"
      ];
      requires = [ "postgresql.service" ];
      wantedBy = [ "multi-user.target" ];
    };
  };

  services.openldap.declarativeContents =
    let
      inherit (rootDomain) sld tld;
    in
    {
      "dc=${sld},dc=${tld}" = lib.mkAfter ''
        dn: cn=${name},ou=groups,dc=${sld},dc=${tld}
        objectClass: groupOfNames
        cn: ${name}
        member: cn=${username},ou=users,dc=${sld},dc=${tld}
      '';
    };

  custom.services.haproxy = {
    backends = [
      {
        inherit name;
        mode = "http";
        servers = [
          {
            name = "server1";
            addr = "127.0.0.127:127";
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
