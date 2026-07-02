{ config, rootDomain, ... }:
let
  name = "thelounge";

  cfg = config.services.${name};
in
{
  services.${name} = {
    enable = true;

    public = false;

    extraConfig = {
      reverseProxy = true;

      defaults = {
        name = "SAG-Chat";
        host = "irc.${rootDomain}";
      };

      ldap = {
        enable = true;
        url = "ldap://localhost";
        baseDN = "ou=users,dc=${rootDomain.sld},dc=${rootDomain.tld}";
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
