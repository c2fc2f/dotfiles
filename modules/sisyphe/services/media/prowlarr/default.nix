{ config, ... }:

{
  services.prowlarr = {
    enable = true;

    settings = {
      server = {
        bindAddress = "127.0.0.96";
      };
    };
  };

  custom.services.haproxy = {
    backends = [
      {
        name = "prowlarr";
        mode = "http";
        servers =
          let
            inherit (config.services.prowlarr.settings.server) bindAddress port;
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
          url = "indexer.sagbot.com";
          backend = "prowlarr";
        }
      ];
    };
  };
}
