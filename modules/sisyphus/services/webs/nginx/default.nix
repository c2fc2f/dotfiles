{
  username,
  config,
  lib,
  mainDomain,
  ...
}:

{
  services.nginx = {
    enable = true;
    virtualHosts = {
      "${mainDomain}" = {
        listen = [
          {
            addr = "127.0.0.80";
            port = 3380;
          }
        ];
        root = "/var/www/${mainDomain}/public_html";
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
        url = mainDomain;
        backend = mainDomain;
      }
    ];

    defaultBackend = mainDomain;
  };
}
