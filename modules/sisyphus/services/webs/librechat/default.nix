{
  config,
  rootDomain,
  username,
  ...
}:
let
  name = "librechat";

  fullDomain = "chat.${rootDomain}";

  inherit (config.services.kanidm.server.settings) domain origin;
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

      OPENID_ISSUER = "${origin}/oauth2/openid/${name}";
      OPENID_CLIENT_ID = name;
      OPENID_CALLBACK_URL = "/oauth/openid/callback";
      OPENID_SCOPE = "openid profile email groups";

      OPENID_USERNAME_CLAIM = "preferred_username";
      OPENID_NAME_CLAIM = "name";
      OPENID_EMAIL_CLAIM = "email";

      OPENID_ADMIN_ROLE = "ai-admins@${domain}";
      OPENID_ADMIN_ROLE_PARAMETER_PATH = "groups";
      OPENID_ADMIN_ROLE_TOKEN_KIND = "id";

      OPENID_USE_END_SESSION_ENDPOINT = true;

      OPENID_BUTTON_LABEL = "Log in SSO";
      OPENID_IMAGE_URL = "https://raw.githubusercontent.com/kanidm/kanidm/refs/heads/master/book/theme/favicon.png";
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

  services.kanidm.provision = {
    enable = true;

    groups = {
      ai-users = {
        members = [ "ai-admins" ];
        overwriteMembers = false;
      };
      ai-admins = {
        members = [ username ];
        overwriteMembers = false;
      };
    };

    systems.oauth2.${name} = {
      displayName = name;
      originUrl = "https://${fullDomain}/";
      originLanding = "https://${fullDomain}/oauth/openid/callback";
      basicSecretFile = config.sops.secrets."librechat/client/secret".path;

      scopeMaps = {
        ai-users = [
          "openid"
          "profile"
          "email"
          "groups"
        ];
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
