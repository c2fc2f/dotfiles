{ config, ... }:
let
  inherit (config.services.rspamd) user group;
  secret = {
    sopsFile = ./secrets.yaml;

    owner = user;
    inherit group;
  };
in
{
  custom.secrets.sisyphus.enable = true;

  sops.secrets = {
    "rspamd/password" = secret;
    "rspamd/spamhaus/dqs" = secret;
  }
  // builtins.listToAttrs (
    map (cert: {
      name = "rspamd/dkim/${cert.domain}/key";
      value = {
        sopsFile = ./dkim/${cert.domain}.key;
        format = "binary";

        owner = user;
        inherit group;
      };
    }) (builtins.attrValues config.security.acme.certs)
  );
}
