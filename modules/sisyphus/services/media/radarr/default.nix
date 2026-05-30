{ config, mainDomain, ... }:
let
  name = "radarr";
in
{
  services.${name} = {
    enable = true;

    settings = {
      app = {
        instancename = "SAGMovies";
      };

      auth = {
        enable = true;
        method = "External";
      };

      server = {
        bindaddress = "127.0.0.78";
        port = 7878;
        urlbase = "/movies";
      };
    };
  };

  custom.services.haproxy = {
    backends = [
      {
        inherit name;
        mode = "http";
        servers =
          let
            inherit (config.services.radarr.settings.server) bindaddress port;
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
          inherit (config.services.radarr.settings.server) urlbase;
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
