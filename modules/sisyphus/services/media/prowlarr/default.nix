{ config, mainDomain, ... }:
let
  name = "prowlarr";

  fullDomain = "media.${mainDomain}";
  inherit (config.custom.services.authelia) mainInstance;
in
{
  services.${name} = {
    enable = true;

    settings = {
      app = {
        instancename = "SAG Indexer";
      };

      auth = {
        enable = true;
        method = "External";
      };

      server = {
        bindaddress = "127.0.0.96";
        port = 9696;
        urlbase = "/indexer";
      };
    };

    environmentFiles = [ config.sops.templates."prowlarr.env".path ];
  };

  sops.templates."prowlarr.env" = {
    content = ''
      PROWLARR__AUTH__APIKEY="${config.sops.placeholder."prowlarr/apiKey"}"
    '';
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
            url = "${fullDomain}${urlbase}";
            backend = name;
            needAuth = true;
          }
        ];
    };
  };

  services.authelia.instances.${mainInstance}.settings.access_control.rules =
    let
      inherit (config.services.${name}.settings.server) urlbase;
    in
    [
      {
        domain = fullDomain;
        resources = [ "^${urlbase}.*" ];
        policy = "two_factor";
        subject = [ "group:admins" ];
      }
      {
        domain = fullDomain;
        resources = [ "^${urlbase}.*" ];
        policy = "deny";
      }
    ];
}
