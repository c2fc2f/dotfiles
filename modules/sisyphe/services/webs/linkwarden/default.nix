{
  config,
  mainDomain,
  ...
}:
let
  name = "linkwarden";
in
{
  services.${name} = {
    enable = true;

    host = "127.0.0.30";
    port = 3000;

    enableRegistration = false;

    environment = {
      NEXT_PUBLIC_CREDENTIALS_ENABLED = "false";
      NEXT_PUBLIC_KEYCLOAK_ENABLED = "true";

      NEXTAUTH_URL = "https://link.${mainDomain}/api/v1/auth";
    };

    secretFiles =
      let
        inherit (config.sops) secrets;
      in
      {
        NEXTAUTH_SECRET = secrets."${name}/nextauth/secret".path;

        KEYCLOAK_ISSUER = secrets."${name}/keycloak/issuer".path;
        KEYCLOAK_CLIENT_ID = secrets."${name}/keycloak/client/id".path;
        KEYCLOAK_CLIENT_SECRET = secrets."${name}/keycloak/client/secret".path;
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
          url = "link.${mainDomain}";
          backend = name;
        }
      ];
    };
  };
}
