{ config, ... }:
let
  inherit (config.services.rspamd) user group;
in
{
  custom.secrets.sisyphus.enable = true;

  sops.secrets = {
    "rspamd/spamhaus/dqs" = {
      sopsFile = ./secrets.yaml;

      owner = user;
      inherit group;
    };
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
