{
  lib,
  config,
  mainDomain,
  ...
}:
let
  name = "sonarr";

  fullDomain = "media.${mainDomain}";
  inherit (config.custom.services.authelia) mainInstance;
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

    environmentFiles = [ config.sops.templates."${name}.env".path ];
  };

  sops.templates."${name}.env" = {
    content = ''
      ${lib.toUpper name}__AUTH__APIKEY="${
        config.sops.placeholder."${name}/apiKey"
      }"
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
