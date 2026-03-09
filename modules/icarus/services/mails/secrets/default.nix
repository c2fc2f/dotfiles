{
  config,
  ...
}:

{
  custom.secrets.icarus.enable = true;

  sops.secrets = {
    "dovecot/introspection_url" = {
      sopsFile = ./dovecot.yaml;

      owner = config.services.dovecot2.user;
    };

    "dovecot/client_secret" = {
      sopsFile = ./dovecot.yaml;

      owner = config.services.dovecot2.user;
    };

    "dovecot/server/sslKey" = {
      sopsFile = ./server.key;

      format = "binary";
      owner = config.services.dovecot2.user;
    };
  };
}
