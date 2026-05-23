{
  config,
  lib,
  clib,
  mainDomain,
  ...
}:
let
  splitDomain = lib.splitString "." mainDomain;
  tld = builtins.elemAt splitDomain 1;
  domain = builtins.elemAt splitDomain 0;

  cfg = config.custom.services.authelia;

  address = "127.0.0.90:9091";
in
{
  options.custom.services.authelia = {
    domain = lib.mkOption {
      type = lib.types.str;
      default = "auth.${mainDomain}";
      description = "The domain for the Authelia service.";
    };

    mainInstance = lib.mkOption {
      type = lib.types.str;
      default = "main";
      description = "The main instance name for Authelia.";
    };
  };

  config = {
    services = {
      authelia.instances.${cfg.mainInstance} = {
        enable = true;

        environmentVariables = {
          AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE =
            config.sops.secrets."openldap/readonly/password".path;
        };

        secrets = {
          jwtSecretFile = config.sops.secrets."authelia/jwtSecret".path;
          oidcHmacSecretFile =
            config.sops.secrets."authelia/oidc/hmacSecret".path;
          oidcIssuerPrivateKeyFile =
            config.sops.secrets."authelia/oidc/jwks/key".path;
          sessionSecretFile =
            config.sops.secrets."authelia/session/secret".path;
          storageEncryptionKeyFile =
            config.sops.secrets."authelia/storage/encryptionKey".path;
        };

        settings = {
          theme = "dark";

          server = {
            address = "tcp://${address}/";
          };

          log = {
            level = "info";
          };

          authentication_backend = {
            password_reset = {
              disable = false;
            };
            password_change = {
              disable = false;
            };

            ldap = {
              implementation = "custom";

              attributes = {
                username = "uid";
                mail = "mail";
                display_name = "givenName";
                group_name = "cn";
              };

              address = "ldaps://localhost";
              base_dn = "dc=${domain},dc=${tld}";

              tls = {
                skip_verify = true;
              };

              additional_users_dn = "ou=users";
              users_filter = clib.rmBlank ''
                (&
                  (|
                    ({username_attribute}={input})
                    ({mail_attribute}={input})
                  )
                  (objectClass=inetOrgPerson)
                )
              '';

              additional_groups_dn = "ou=groups";
              groups_filter = "(member={dn})";

              user = "cn=readonly,dc=${domain},dc=${tld}";
            };
          };

          session = {
            name = "${domain}-session";

            cookies = [
              {
                domain = mainDomain;
                authelia_url = "https://${cfg.domain}";
                default_redirection_url = "https://${mainDomain}";
              }
            ];

            redis = {
              host = config.services.redis.servers.authelia.unixSocket;
            };
          };

          default_2fa_method = "webauthn";
          webauthn = {
            enable_passkey_login = true;
            experimental_enable_passkey_uv_two_factors = true;

            display_name = lib.toUpper domain;
          };

          access_control = {
            default_policy = "deny";
            rules = [
              {
                domain = "*.${mainDomain}";
                policy = "two_factor";
              }
            ];
          };

          storage = {
            postgres = {
              address = "unix:///run/postgresql";
              database = config.services.authelia.instances.main.user;
              username = config.services.authelia.instances.main.user;
            };
          };

          notifier = {
            smtp = {
              address = "smtp://localhost:25";
              sender = "SAG-Auth <auth@sagbot.com>";
              subject = "[SAG-Auth] {title}";

              tls = {
                skip_verify = true;
              };
            };
          };
        };
      };

      postgresql = {
        ensureDatabases = [ config.services.authelia.instances.main.user ];
        ensureUsers = [
          {
            name = config.services.authelia.instances.main.user;
            ensureDBOwnership = true;
          }
        ];
      };

      redis.servers.authelia.enable = true;
    };

    users.groups = {
      openldap.members = [ config.services.authelia.instances.main.user ];
      redis-authelia.members = [
        config.services.authelia.instances.main.user
      ];
    };

    custom.services.haproxy = {
      backends = [
        {
          name = "authelia";
          mode = "http";
          servers = [
            {
              name = "server1";
              addr = address;
              check = true;
            }
          ];
        }
      ];

      maps = {
        url = [
          {
            url = cfg.domain;
            backend = "authelia";
          }
        ];
      };
    };
  };
}
