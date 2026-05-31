{
  config,
  pkgs,
  lib,
  clib,
  ...
}:
let
  cfg = config.custom.services.haproxy;

  certMap = pkgs.writeText "haproxy-cert.map" (
    lib.strings.concatLines (
      builtins.map (cert: "${cert.directory}/full.pem") (
        builtins.attrValues config.security.acme.certs
      )
    )
  );

  makeMap =
    map:
    pkgs.writeText "haproxy-url.map" (
      lib.strings.concatLines (
        builtins.map (e: "${e.url} ${e.backend}") map
      )
    );

  makeAuthMap =
    map:
    pkgs.writeText "haproxy-auth.map" (
      lib.strings.concatLines (
        builtins.map (e: "${e.url} true") (
          builtins.filter (e: e.needAuth) map
        )
      )
    );

  haproxy_minecraft = pkgs.stdenv.mkDerivation {
    pname = "haproxy_minecraft-patch";
    version = "1.0";

    src = pkgs.fetchurl {
      url = "https://gist.githubusercontent.com/nathan818fr/a078e92604784ad56e84843ebf99e2e5/raw/3d9c74eec578aa0c0a177369d7106fe224b03efd/haproxy_minecraft.lua";
      hash = "sha256-9+du5t3tZ0rJw+7/1Y9O8vIHFwvev3HIx/vsgBm2P08=";
    };

    patches = [ ./assets/haproxy_minecraft.patch ];

    unpackPhase = ''
      cp $src haproxy_minecraft.lua
    '';

    patchPhase = ''
      patch -p0 < ${./assets/haproxy_minecraft.patch}
    '';

    installPhase = ''
      mkdir -p $out
      cp haproxy_minecraft.lua $out/
    '';
  };

  haproxy_auth_request = pkgs.stdenv.mkDerivation {
    pname = "haproxy-auth-request";
    version = "cdb891c";

    src = pkgs.fetchFromGitHub {
      owner = "TimWolla";
      repo = "haproxy-auth-request";
      rev = "cdb891c";
      hash = "sha256-1JibFpzfDljK8gMJUilQaWHuxQ0hRvQesu8wCB4MbCI=";
    };

    luaHttpSrc = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/haproxytech/haproxy-lua-http/master/http.lua";
      hash = "sha256-4e8BmV+wQPgsrS4ULQFmLRIJ/tgcGabJdo0Zkk6w794=";
    };

    jsonLuaSrc = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/rxi/json.lua/master/json.lua";
      hash = "sha256-DqzNpX+rwDMHNt4l9Fz1iYIaQrXg/gLk4xJffcC/K34=";
    };

    installPhase = ''
      mkdir -p $out/share/lua
      cp auth-request.lua $out/

      cp $luaHttpSrc $out/share/lua/haproxy-lua-http.lua
      cp $jsonLuaSrc $out/share/lua/json.lua
    '';
  };

  frontendsConfig = lib.removeSuffix "\n" (
    lib.strings.concatLines (
      builtins.map (e: ''
        frontend ${e.name}
          bind ${e.bind}
          ${lib.optionalString (e.mode != null) "mode ${e.mode}"}
        ${clib.indent 2 e.extraConfig}
      '') cfg.frontends
    )
  );

  backendsConfig = lib.removeSuffix "\n" (
    lib.strings.concatLines (
      builtins.map (e: ''
        backend ${e.name}
          ${lib.optionalString (e.mode != null) "mode ${e.mode}"}
          ${lib.optionalString (e.balance != null) "balance ${e.balance}"}
        ${clib.indent 2 e.extraConfig}

        ${clib.indent 2 (serversConfig e.servers)}
      '') cfg.backends
    )
  );

  serversConfig =
    servers:
    lib.strings.concatLines (
      builtins.map (
        e: "server ${e.name} ${e.addr}${lib.optionalString e.check " check"}"
      ) servers
    );

  maxconn = lib.mkOption {
    type = lib.types.nullOr lib.types.ints.positive;
    description = "Set a process-wide maximum number of connections available";
  };

  extraConfig = lib.mkOption {
    type = lib.types.lines;
    default = "";
    description = ''
      Additional configuration.
    '';
  };
in
{
  options.custom.services.haproxy = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable HAProxy.
      '';
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.haproxy;
      description = "The HAProxy package to use";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "haproxy";
      description = "User account under which haproxy runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "haproxy";
      description = "Group account under which haproxy runs.";
    };

    global = {
      inherit maxconn extraConfig;

      daemon = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Makes the process fork into background.";
      };
    };

    defaults = { inherit maxconn extraConfig; };

    authz = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enable Authz authentication.
        '';
      };

      backend = lib.mkOption {
        type = lib.types.enum (builtins.map (e: e.name) cfg.backends);
        description = "Backend of the Authz authenticator";
      };

      path = lib.mkOption {
        type = lib.types.str;
        description = "Path to request to verify";
      };

      extraArgs = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Extra arguments given to request to verify";
      };
    };

    defaultBackend = lib.mkOption {
      type = lib.types.enum (
        (builtins.map (e: e.name) cfg.backends) ++ [ "close_connection" ]
      );
      default = "close_connection";
      description = "Default backend that will be used if no element in the mapUrl matches";
    };

    backends = lib.mkOption {
      type =
        with lib.types;
        listOf (submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "Name of the backend";
            };

            mode = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Protocol used";
            };

            balance = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Which balancer to use";
            };

            servers = lib.mkOption {
              type =
                with lib.types;
                listOf (submodule {
                  options = {
                    name = lib.mkOption {
                      type = lib.types.str;
                      description = "Name of the server";
                    };

                    addr = lib.mkOption {
                      type = lib.types.str;
                      description = "Address of the server";
                    };

                    check = lib.mkOption {
                      type = lib.types.bool;
                      default = false;
                      description = "Check if the serveur is up";
                    };
                  };
                });
              default = [ ];
              description = ''
                List of servers
              '';
            };

            inherit extraConfig;
          };
        });
      default = [ ];
      description = ''
        List of backends
      '';
    };

    frontends = lib.mkOption {
      type =
        with lib.types;
        listOf (submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "Name of the backend";
            };

            bind = lib.mkOption {
              type = lib.types.str;
              description = "Address bind";
            };

            mode = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Protocol used";
            };

            inherit extraConfig;
          };
        });
      default = [ ];
      description = ''
        List of frontend
      '';
    };

    maps = {
      minecraft = lib.mkOption {
        type =
          with lib.types;
          listOf (submodule {
            options = {
              url = lib.mkOption {
                type = lib.types.str;
                description = "Regex that matches the URL that the request must match";
              };

              backend = lib.mkOption {
                type = lib.types.enum (builtins.map (e: e.name) cfg.backends);
                description = "Backend that will be used when the request URL matches.";
              };
            };
          });
        default = [ ];
        description = ''
          Map of regex to match the right backend for the URL
        '';
      };

      url = lib.mkOption {
        type =
          with lib.types;
          listOf (submodule {
            options = {
              url = lib.mkOption {
                type = lib.types.str;
                description = "Regex that matches the URL that the request must match";
              };

              backend = lib.mkOption {
                type = lib.types.enum (builtins.map (e: e.name) cfg.backends);
                description = "Backend that will be used when the request URL matches.";
              };

              needAuth = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Require Authz authentication for this URL.";
              };
            };
          });
        default = [ ];
        description = ''
          Map of regex to match the right backend for the URL
        '';
      };
    };

    inherit extraConfig;
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          cfg.authz.enable || !(builtins.any (u: u.needAuth) cfg.maps.url);
        message = "Authentication must be enabled (cfg.authz.enable = true) if any URL requires it (needAuth = true).";
      }
    ];

    services.haproxy = {
      inherit (cfg)
        enable
        package
        user
        group
        ;

      config = ''

        global
          user ${cfg.user}
          group ${cfg.group}
          ${lib.optionalString (
            cfg.global.maxconn != null
          ) "maxconn ${toString cfg.global.maxconn}"}
          ${lib.optionalString cfg.global.daemon "daemon"}
          ssl-default-bind-options ssl-min-ver TLSv1.2 
          ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
          tune.lua.bool-sample-conversion normal
          lua-load ${haproxy_minecraft}/haproxy_minecraft.lua
        ${lib.optionalString cfg.authz.enable (
          clib.indent 2 ''
            lua-prepend-path ${haproxy_auth_request}/share/lua/?.lua
            lua-load ${haproxy_auth_request}/auth-request.lua
          ''
        )}
        ${clib.indent 2 cfg.global.extraConfig}

        defaults
          ${lib.optionalString (
            cfg.defaults.maxconn != null
          ) "maxconn ${toString cfg.defaults.maxconn}"}
        ${clib.indent 2 cfg.defaults.extraConfig}

        # ============== DEFAULT FRONTEND ==+=============
        frontend http-in
          bind :::80 v4v6
          mode http
          redirect scheme https code 301 if !{ ssl_fc }

        frontend https-in
          bind :::443 v4v6 ssl crt-list ${certMap}
          mode http
          option http-server-close
          option forwardfor
          http-request set-header X-Forwarded-Proto https if { ssl_fc }
          http-response set-header Strict-Transport-Security "max-age=16000000; includeSubDomains; preload;"

        ${lib.optionalString cfg.authz.enable (
          clib.indent 2 ''
            acl requires_auth base,map_beg(${makeAuthMap cfg.maps.url}) -m found

            http-request del-header X-Forwarded-For if requires_auth

            acl hdr-xff_exists req.hdr(X-Forwarded-For) -m found
            http-request set-header X-Forwarded-For %[src] if !hdr-xff_exists
            option forwardfor

            http-request set-var(req.scheme) str(https) if { ssl_fc }
            http-request set-var(req.scheme) str(http) if !{ ssl_fc }
            http-request set-var(req.questionmark) str(?) if { query -m found }

            http-request set-header X-Forwarded-Method %[method]
            http-request set-header X-Forwarded-Proto  %[var(req.scheme)]
            http-request set-header X-Forwarded-Host   %[req.hdr(Host)]
            http-request set-header X-Forwarded-URI    %[path]%[var(req.questionmark)]%[query]

            http-request lua.auth-intercept ${cfg.authz.backend} ${cfg.authz.path} ${cfg.authz.extraArgs} if requires_auth

            http-request deny if requires_auth !{ var(txn.auth_response_successful) -m bool } { var(txn.auth_response_code) -m int 403 }
            http-request redirect location %[var(txn.auth_response_location)] if requires_auth !{ var(txn.auth_response_successful) -m bool }
          ''
        )}

          use_backend %[base,map_beg(${makeMap cfg.maps.url},${cfg.defaultBackend})]

        frontend minecraft
          bind :::25565 v4v6
          mode tcp

          tcp-request inspect-delay 1s
          tcp-request content lua.mc_handshake
          tcp-request content reject if { var(txn.mc_proto) -m int 0 }
          tcp-request content accept if { var(txn.mc_proto) -m found }
          tcp-request content reject if WAIT_END

          use_backend %[var(txn.mc_host),map_beg(${makeMap cfg.maps.minecraft},close_connection)]

        # =============== CUSTOM FRONTEND ================
        ${frontendsConfig}

        # =============== DEFAULT BACKEND ================
        backend close_connection
          mode tcp
          timeout connect 1ms
          timeout server 1ms
          tcp-request content reject

        # ================ CUSTOM BACK END ===============
        ${backendsConfig}

        # ================= EXTRA CONFIG =================
        ${cfg.extraConfig}
      '';
    };

    users.groups.acme.members = [ cfg.user ];

    security.acme.defaults.reloadServices = [ "haproxy" ];

    networking.firewall.allowedTCPPorts = [
      80
      443
      25565
    ];
  };
}
