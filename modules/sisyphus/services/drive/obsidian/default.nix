{ config, ... }:
let
  name = "obsidian";
in
{
  custom.services.couchdb = {
    enable = true;

    users = {
      ${name} = {
        passwordFile = config.sops.secrets."${name}/couchdb/password".path;
        ensureDBOwnership = true;
      };
    };
  };
}
