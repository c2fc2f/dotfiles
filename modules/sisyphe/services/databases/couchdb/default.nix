{ config, mainDomain, ... }:
let
  name = "couchdb";
in
{
  services.${name} = {
    enable = true;

    extraConfigFiles = [ config.sops.secrets."couchdb/admin".path ];

    bindAddress = "127.0.0.59";
    port = 5984;
  };

  custom.services.haproxy = {
    backends = [
      {
        inherit name;
        mode = "http";
        servers =
          let
            inherit (config.services.${name}) bindAddress port;
          in
          [
            {
              name = "server1";
              addr = "${bindAddress}:${toString port}";
              check = true;
            }
          ];
      }
    ];

    maps = {
      url = [
        {
          url = "couchdb.${mainDomain}";
          backend = name;
        }
      ];
    };
  };
}
