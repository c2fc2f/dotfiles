{ atacc-homepage, config, ... }:
let
  name = "atacc-homepage";
  fullDomain = "atacc.org";
in
{
  imports = [ atacc-homepage.nixosModules.default ];

  services.${name} = {
    enable = true;

    host = "127.0.0.65";
    port = 3365;
    publicUrl = "https://${fullDomain}";

    smtp = {
      host = "localhost";
      port = 25;
      security = "none";

      username = "no-reply@atacc.org";
      passwordFile = null;

      fromAddress = "ATACC <no-reply@atacc.org>";
    };
  };

  custom.services.haproxy = {
    backends = [
      {
        inherit name;
        mode = "http";
        servers =
          let
            inherit (config.services.${name}) host port;
          in
          [
            {
              name = "server1";
              addr = "${host}:${toString port}";
              check = true;
            }
          ];
      }
    ];

    maps = {
      url = [
        {
          url = fullDomain;
          backend = name;
        }
      ];
    };
  };
}
