{ config, mainDomain, ... }:
let
  name = "librechat";

  fullDomain = "chat.${mainDomain}";

  inherit (config.custom.services.authelia) mainInstance domain;
in
{
  services.${name} = {
    enable = true;

    enableLocalDB = true;

    settings = {
      version = "1.3.5";
      cache = true;
      endpoints = {
        custom = [
          {
            name = "Ollama";
            apiKey = "ollama";
            baseURL =
              let
                inherit (config.services.ollama) host port;
              in
              "http://${host}:${toString port}/v1/";
            models = {
              default = config.services.ollama.loadModels;
              fetch = true;
            };
            titleConvo = true;
            titleModel = "current_model";
            modelDisplayLabel = "Ollama";
          }
          {
            name = "OpenRouter";
            apiKey = "openrouter";
            baseURL =
              let
                inherit (config.services.hermux.listen) address port;
              in
              "http://${address}:${toString port}/api/v1";
            models = {
              default = [ "openai/whisper-1" ];
              fetch = true;
            };
            titleConvo = true;
            titleModel = "current_model";
            dropParams = [ "stop" ];
            modelDisplayLabel = "OpenRouter";
          }
        ];
      };
    };

    env = {
      HOST = "127.0.0.38";
      PORT = "3080";

      DOMAIN_CLIENT = "https://${fullDomain}";
      DOMAIN_SERVER = "https://${fullDomain}";
      ADMIN_PANEL_URL = "https://${fullDomain}/admin";

      ALLOW_EMAIL_LOGIN = false;
      ALLOW_REGISTRATION = false;

      ALLOW_SOCIAL_LOGIN = true;
      ALLOW_SOCIAL_REGISTRATION = true;

      OPENID_ISSUER = "https://${domain}/.well-known/openid-configuration";
      OPENID_CLIENT_ID = name;
      OPENID_CALLBACK_URL = "/oauth/openid/callback";
      OPENID_SCOPE = "openid profile email";

      OPENID_USERNAME_CLAIM = "preferred_username";
      OPENID_NAME_CLAIM = "name";
      OPENID_EMAIL_CLAIM = "email";

      OPENID_ADMIN_ROLE = "admins";

      OPENID_USE_END_SESSION_ENDPOINT = true;

      OPENID_BUTTON_LABEL = "Log in SSO";
      OPENID_IMAGE_URL = "https://www.authelia.com/images/branding/logo-cropped.png";
    };

    credentials =
      let
        inherit (config.sops) secrets;
      in
      {
        OPENID_SESSION_SECRET = secrets."librechat/session/secret".path;
        OPENID_CLIENT_SECRET = secrets."librechat/client/secret".path;
        JWT_SECRET = secrets."librechat/jwt/secret".path;
        JWT_REFRESH_SECRET = secrets."librechat/jwt/refresh/secret".path;
        CREDS_KEY = secrets."librechat/creds/key".path;
        CREDS_IV = secrets."librechat/creds/iv".path;
      };
  };

  services.authelia.instances.${mainInstance}.settings.identity_providers =
    {
      oidc.clients = [
        {
          client_id = name;
          client_name = name;
          client_secret = "$argon2id$v=19$m=65536,t=3,p=4$Hd8nc1FwoNwAOVfyvogLkw$yf6etSPC9ZzRVwWdj6JBhKKWEc4HMCFr1bBS1LOpmek";
          public = false;
          require_pkce = false;
          pkce_challenge_method = "";
          consent_mode = "implicit";
          redirect_uris = [ "https://${fullDomain}/oauth/openid/callback" ];
          scopes = [
            "openid"
            "email"
            "profile"
          ];
          response_types = [ "code" ];
          grant_types = [
            "authorization_code"
            "refresh_token"
          ];
          access_token_signed_response_alg = "none";
          userinfo_signed_response_alg = "none";
          token_endpoint_auth_method = "client_secret_post";
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
            inherit (config.services.${name}.env) HOST PORT;
          in
          [
            {
              name = "server1";
              addr = "${HOST}:${toString PORT}";
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
