{
  config,
  ...
}:

{
  custom.secrets.sisyphus.enable = true;

  sops.secrets."rspamd/password" =
    let
      inherit (config.services.rspamd) user group;
    in
    {
      sopsFile = ./secrets.yaml;

      owner = user;
      inherit group;
    };
}
