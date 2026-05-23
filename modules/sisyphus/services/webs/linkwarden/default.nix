{
  config,
  pkgs,
  mainDomain,
  ...
}:
let
  name = "linkwarden";

  fullDomain = "link.${mainDomain}";

  inherit (config.custom.services.authelia) mainInstance;
in
{
  services.${name} = {
    enable = true;

    host = "127.0.0.30";
    port = 3000;

    enableRegistration = false;

    environment = {
      NEXT_PUBLIC_CREDENTIALS_ENABLED = "false";
      NEXT_PUBLIC_AUTHELIA_ENABLED = "true";

      NEXTAUTH_URL = "https://${fullDomain}/api/v1/auth";
    };

    secretFiles =
      let
        inherit (config.sops) secrets;
      in
      {
        NEXTAUTH_SECRET = secrets."${name}/nextauth/secret".path;

        AUTHELIA_WELLKNOWN_URL =
          let
            inherit (config.custom.services.authelia) domain;
          in
          toString (
            pkgs.writeText "linkwarden_wellknown" "https://${domain}/.well-known/openid-configuration"
          );
        AUTHELIA_CLIENT_ID = toString (
          pkgs.writeText "linkwarden_client_id" name
        );
        AUTHELIA_CLIENT_SECRET = secrets."${name}/client/secret".path;
      };
  };

  services.authelia.instances.${mainInstance}.settings.identity_providers =
    {
      oidc.clients = [
        {
          client_id = name;
          client_name = name;
          client_secret = "$pbkdf2-sha512$310000$wCa.ZeWpd84CvOQa79bqqQ$0rtOYbR1qr92GHiP/13ChGP11dCbFi4tzOFPy3JwAJARUaz62cd7H478M28PXw4oBxN6bxvPfM6034OslhbPRg";
          public = false;
          consent_mode = "implicit";
          scopes = [
            "openid"
            "groups"
            "email"
            "profile"
          ];
          redirect_uris = [
            "https://${fullDomain}/api/v1/auth/callback/authelia"
          ];
          userinfo_signed_response_alg = null;
        }
      ];
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
