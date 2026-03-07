{
  config,
  mainDomain,
  ...
}:
let
  name = "immich";
in
{
  services.${name} = {
    enable = true;

    host = "127.0.0.228";
    port = 2283;

    settings = {
      oauth = {
        enabled = true;

        clientId = name;
        clientSecret._secret = config.sops.secrets."immich/oauth/secret".path;
        issuerUrl =
          let
            inherit (config.services.keycloak.settings) hostname;
          in
          "${hostname}/realms/master/.well-known/openid-configuration";

        autoLaunch = true;
        autoRegister = true;

        roleClaim = "${name}_role";
        storageLabelClaim = "firstName";
      };

      passwordLogin = {
        enabled = false;
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
            inherit (config.services.immich) host port;
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
          url = "photo.${mainDomain}";
          backend = name;
        }
      ];
    };
  };
}
