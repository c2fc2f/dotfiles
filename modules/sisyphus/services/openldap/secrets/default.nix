{
  config,
  username,
  ...
}:

{
  custom.secrets.sisyphus.enable = true;

  sops.secrets."openldap/${username}/password" =
    let
      inherit (config.services.openldap) user group;
    in
    {
      sopsFile = ./secrets.yaml;

      owner = user;
      inherit group;
    };
}
