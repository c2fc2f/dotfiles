{
  config,
  ...
}:

{
  custom.secrets.sisyphe.enable = true;

  sops.secrets."atacc/env" =
    let
      inherit (config.systemd.services.atacc.serviceConfig) User Group;
    in
    {
      sopsFile = ./environement;
      format = "binary";

      owner = User;
      group = Group;
    };

}
