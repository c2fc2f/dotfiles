{
  sops-nix,
  ...
}:

{
  imports = [
    sops-nix.nixosModules.sops
  ];

  # , sops -a "$(cat key.pub | , ssh-to-age)" file.toml
  sops.defaultSopsFormat = "yaml";
}
