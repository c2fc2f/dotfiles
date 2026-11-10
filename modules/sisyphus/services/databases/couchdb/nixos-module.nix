{
  config,
  lib,
  pkgs,
  rootDomain,
  ...
}:

let
  name = "couchdb";

  cfg = config.services.${name};
  customCfg = config.custom.services.${name};
  fullDomain = "${name}.${rootDomain}";
in
{
  options.custom.services.${name} = {
    enable = lib.mkEnableOption name;

    users = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            passwordFile = lib.mkOption {
              type = lib.types.str;
              description = "Path to the file containing the user's password.";
            };

            ensureDBOwnership = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Automatically create a database named after this user and assign them full ownership permissions.";
            };
          };
        }
      );
      default = { };
      description = "Attribute set of CouchDB users to create automatically on startup.";
      example = {
        "alice" = {
          passwordFile = "/run/secrets/couchdb/alice/password";
        };
      };
    };
  };

  config = lib.mkIf customCfg.enable {
    services.${name} = {
      enable = true;

      bindAddress = "127.0.59.84";
      port = 5984;

      extraConfig = {
        couchdb = {
          single_node = true;
          max_document_size = 50 * 1024 * 1024;
        };

        httpd = {
          enable_cors = true;
          WWW-Authenticate = "Basic realm=\"${name}\"";
        };

        chttpd = {
          enable_cors = true;
          require_valid_user_except_for_up = true;
          max_http_request_size = 4 * 1024 * 1024 * 1024;
        };

        chttpd_auth = {
          require_valid_user = true;
        };

        cors = {
          origins = lib.concatStringsSep ", " [
            "app://obsidian.md"
            "capacitor://localhost"
            "http://localhost"
          ];
          credentials = true;
        };
      };

      adminUser = "admin";
      extraConfigFiles = [
        config.sops.templates."secrets-${name}.ini".path
      ];
    };

    sops.templates."secrets-${name}.ini" = {
      content = ''
        [admins]
        ${cfg.adminUser}=${config.sops.placeholder."${name}/admin/password"}
      '';

      owner = cfg.user;
      inherit (cfg) group;
    };

    systemd.services.${name}.serviceConfig.ExecStartPost =
      let
        couchdbUrl = "http://${cfg.bindAddress}:${toString cfg.port}";

        usersJsonFile = pkgs.writeText "${name}-users.json" (
          builtins.toJSON customCfg.users
        );
      in

      lib.mkAfter [
        "+${
          lib.getExe (
            pkgs.writeShellApplication {
              name = "init-couchdb-users";

              runtimeInputs = with pkgs; [
                curl
                jq
              ];

              text = ''
                ADMIN_PASS=$(<"${config.sops.secrets."${name}/admin/password".path}")

                echo "Waiting for CouchDB to become responsive..."
                elapsed=0
                TIMEOUT_SEC=30

                until curl -sf -o /dev/null \
                  -u "${cfg.adminUser}:$ADMIN_PASS" \
                  "${couchdbUrl}/_users"; do
                  if [ "$elapsed" -ge "$TIMEOUT_SEC" ]; then
                    echo "Error: CouchDB did not become ready within $TIMEOUT_SEC seconds." >&2
                    exit 1
                  fi
                  sleep 1
                  elapsed=$((elapsed + 1))
                done

                echo "CouchDB is up and responsive."

                jq -c 'to_entries[]' "${usersJsonFile}" | while read -r entry; do
                  user=$(echo "$entry" | jq -r '.key')
                  pwdFile=$(echo "$entry" | jq -r '.value.passwordFile')
                  ensureDBOwnership=$(echo "$entry" | jq -r '.value.ensureDBOwnership')

                  echo "Checking if user '$user' exists..."
                  USER_DOC_ID="org.couchdb.user:$user"

                  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
                    -u "${cfg.adminUser}:$ADMIN_PASS" \
                    "${couchdbUrl}/_users/$USER_DOC_ID")

                  if [ "$HTTP_CODE" = "404" ]; then
                    echo "Creating user '$user'..."

                    JSON_PAYLOAD=$(jq -n \
                      --arg name "$user" \
                      --rawfile pwd "$pwdFile" \
                      '{name: $name, password: $pwd, roles: [], type: "user"}')

                    curl -sf -X PUT \
                      -u "${cfg.adminUser}:$ADMIN_PASS" \
                      -H "Content-Type: application/json" \
                      -d "$JSON_PAYLOAD" \
                      "${couchdbUrl}/_users/$USER_DOC_ID"

                    echo "User '$user' creation process completed."
                  else
                    echo "User '$user' already exists or another HTTP error occurred (HTTP $HTTP_CODE)."
                  fi

                  if [ "$ensureDBOwnership" = "true" ]; then
                    echo "Ensuring database '$user' exists..."
                    curl -sf -X PUT -u "${cfg.adminUser}:$ADMIN_PASS" "${couchdbUrl}/$user" > /dev/null || true

                    echo "Configuring ownership permissions for '$user' on database '$user'..."
                    PERM_PAYLOAD=$(jq -n --arg u "$user" '{admins: {names: [$u], roles: []}, members: {names: [$u], roles: []}}')
                    curl -sf -X PUT \
                      -u "${cfg.adminUser}:$ADMIN_PASS" \
                      -H "Content-Type: application/json" \
                      -d "$PERM_PAYLOAD" \
                      "${couchdbUrl}/$user/_security" > /dev/null
                  fi
                done
              '';
            }
          )
        }"
      ];

    custom.services.haproxy = {
      backends = [
        {
          inherit name;
          mode = "http";
          extraConfig = ''
            option httpchk GET /_up
            http-check expect string '"status":"ok"'
          '';
          servers = [
            {
              name = "server1";
              addr = "${cfg.bindAddress}:${toString cfg.port}";
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

  };
}
