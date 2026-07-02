{
  username,
  config,
  lib,
  rootDomain,
  ...
}:

{
  services.nginx = {
    enable = true;
    virtualHosts = {
      ${toString rootDomain} = {
        listen = [
          {
            addr = "127.0.0.80";
            port = 3380;
          }
        ];
        root = "/var/www/${rootDomain}/public";
        extraConfig = ''
          index index.html;
          absolute_redirect off;
        '';
      };
    };
  };

  users.users.${username}.extraGroups = [ "nginx" ];

  custom.services.haproxy = {
    backends = lib.mapAttrsToList (name: value: {
      inherit name;
      mode = "http";
      servers =
        let
          server = lib.head value.listen;
        in
        [
          {
            name = "server1";
            addr = "${server.addr}:${toString server.port}";
            check = true;
          }
        ];
    }) config.services.nginx.virtualHosts;

    maps.url = [
      {
        url = toString rootDomain;
        backend = toString rootDomain;
      }
    ];

    defaultBackend = toString rootDomain;
  };
}
