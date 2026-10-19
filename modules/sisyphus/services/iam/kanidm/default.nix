{
  config,
  pkgs,
  lib,
  username,
  rootDomain,
  ...
}:
let
  fullDomain = "idm.${rootDomain}";

  name = "kanidm";
  cfg = config.services.${name};
in
{
  services.${name} = {
    package = pkgs.kanidm_1_11.withSecretProvisioning;

    client = {
      enable = true;

      settings = {
        uri = cfg.server.settings.origin;
      };
    };

    server = {
      enable = true;

      settings =
        let
          certDir = config.security.acme.certs.${toString rootDomain}.directory;
        in
        {
          domain = toString rootDomain;
          origin = "https://${fullDomain}";

          bindaddress = "127.0.0.84:8443";

          http_client_address_info = {
            x-forward-for = [
              "127.0.0.1"
              "127.0.0.84"
            ];
          };

          # ldapbindaddress = "[::1]:636";

          tls_chain = "${certDir}/fullchain.pem";
          tls_key = "${certDir}/key.pem";
        };

      entryManagement.migrations = {
        "00-basics" = {
          id = "0f4ae3dd-28e8-4e8c-9a2b-817f7394a8cc";
          assertions = [
            {
              state = "present";
              id = "c2fc2f00-0000-0000-0000-000000000000";
              class = [
                "account"
                "person"
              ];
              name = username;
              displayname = username;
              legalname = username;
              mail = [
                {
                  value = "${username}@${rootDomain}";
                  primary = true;
                }
              ];
            }
          ];
        };
      };
    };

    provision = {
      enable = true;

      adminPasswordFile =
        config.sops.secrets."kanidm/adminPasswordFile".path;
      idmAdminPasswordFile =
        config.sops.secrets."kanidm/idmAdminPasswordFile".path;

      instanceUrl = cfg.server.settings.origin;
    };
  };

  systemd.services."${name}-provision" = {
    wantedBy = [ "multi-user.target" ];

    requires = [ "${name}.service" ];
    after = [ "${name}.service" ];
    bindsTo = [ "${name}.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;

      ExecStart = lib.getExe (
        pkgs.writeShellApplication {
          name = "${name}-provision";
          runtimeInputs = [ cfg.package ];
          text = ''
            KANIDM_NAME="admin"
            KANIDM_PASSWORD=$(< ${cfg.provision.adminPasswordFile})
            export KANIDM_NAME
            export KANIDM_PASSWORD

            kanidm login

            kanidm group add-members idm_high_privilege ${username}

            kanidm logout
          '';
        }
      );
    };
  };

  users.groups.acme.members = [ name ];

  custom.services.haproxy = {
    backends = [
      {
        inherit name;
        mode = "http";
        extraConfig = ''
          option httpchk GET /status
          http-check expect string true
        '';
        servers = [
          {
            name = "server1";
            addr = cfg.server.settings.bindaddress;
            check = true;
            parameters = [
              "ssl"
              "verify none"
            ];
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

  networking.hosts = {
    "127.0.0.1" = [ fullDomain ];
    "::1" = [ fullDomain ];
  };
}
