{ config, mainDomain, ... }:
let
  name = "sonarr";
in
{
  services.${name} = {
    enable = true;

    settings = {
      app = {
        instancename = "SAG Series";
      };

      auth = {
        enable = true;
        method = "External";
      };

      server = {
        bindaddress = "127.0.0.89";
        port = 8989;
        urlbase = "/series";
      };
    };
  };

  users.groups.${config.custom.media.group}.members = [ name ];

  custom.services.haproxy = {
    backends = [
      {
        inherit name;
        mode = "http";
        servers =
          let
            inherit (config.services.${name}.settings.server) bindaddress port;
          in
          [
            {
              name = "server1";
              addr = "${bindaddress}:${toString port}";
              check = true;
            }
          ];
      }
    ];

    maps = {
      url =
        let
          inherit (config.services.${name}.settings.server) urlbase;
        in
        [
          {
            url = "media.${mainDomain}${urlbase}";
            backend = name;
            needAuth = true;
          }
        ];
    };
  };
}
