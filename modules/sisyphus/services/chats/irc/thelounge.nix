{
  lib,
  config,
  mainDomain,
  ...
}:
let
  name = "thelounge";

  cfg = config.services.${name};

  splitDomain = lib.splitString "." mainDomain;
  tld = builtins.elemAt splitDomain 1;
  domain = builtins.elemAt splitDomain 0;
in
{
  services.${name} = {
    enable = true;

    public = false;

    extraConfig = {
      reverseProxy = true;

      defaults = {
        name = "SAG-Chat";
        host = "irc.${mainDomain}";
      };

      ldap = {
        enable = true;
        url = "ldap://localhost";
        baseDN = "ou=users,dc=${domain},dc=${tld}";
        primaryKey = "cn";
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
            addr = "127.0.0.1:${toString cfg.port}";
            check = true;
          }
        ];
      }
    ];

    maps = {
      url = [
        {
          url = cfg.extraConfig.defaults.host;
          backend = name;
        }
      ];
    };
  };
}
