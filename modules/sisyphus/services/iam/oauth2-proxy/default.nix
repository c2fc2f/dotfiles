{ config, rootDomain, ... }:
let
  name = "oauth2-proxy";
  cfg = config.services.${name};

  fullDomain = "oauth2.${rootDomain}";
  inherit (config.services.kanidm.server.settings) origin;
in
{
  services = {
    ${name} = {
      enable = true;

      httpAddress = "127.0.0.180:4180";

      provider = "oidc";
      clientID = name;
      clientSecretFile = config.sops.secrets."${name}/client/secret".path;
      oidcIssuerUrl = "${origin}/oauth2/openid/${name}";

      redirectURL = "https://${fullDomain}/oauth2/callback";

      cookie = {
        domain = ".${rootDomain}";
        secretFile = config.sops.secrets."${name}/cookie/secret".path;
        expire = "12h";
        refresh = "15m";
      };
      email = {
        domains = [ (toString rootDomain) ];
      };

      setXauthrequest = true;
      reverseProxy = true;
      trustedProxyIP = [ "127.0.0.1" ];
      extraConfig = {
        "session-store-type" = "redis";
        "redis-connection-url" =
          let
            inherit (config.services.redis.servers.${name}) bind port;
          in
          "redis://${bind}:${toString port}";
        "cookie-samesite" = "lax";
        "whitelist-domain" = ".${rootDomain}";
        "code-challenge-method" = "S256";
        "scope" = "openid profile email groups";
      };
    };

    redis.servers.${name} = {
      enable = true;
      bind = "127.0.180.63";
      port = 6380;
    };

    kanidm.provision = {
      enable = true;

      systems.oauth2.${name} = {
        displayName = name;
        originUrl = "https://${fullDomain}";
        originLanding = "https://${fullDomain}/oauth2/callback";
        basicSecretFile = config.sops.secrets."${name}/client/secret".path;

        scopeMaps = {
          idm_all_persons = [
            "openid"
            "profile"
            "email"
            "groups"
          ];
        };
      };
    };
  };

  custom.services.haproxy = {
    auth = {
      enable = true;
      backend = name;
      path = "/oauth2/auth";
      extraArgs = "HEAD * - -";
      url = "https://${fullDomain}";
    };

    backends = [
      {
        inherit name;
        mode = "http";
        extraConfig = "option httpchk GET /ping";
        servers = [
          {
            name = "server1";
            addr = cfg.httpAddress;
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
