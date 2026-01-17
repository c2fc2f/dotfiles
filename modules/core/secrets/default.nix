{
  config,
  hostName,
  username,
  groups,
  sops-nix,
  ...
}:
let
  inherit (config.users.users.${username}) home;
in
{
  imports = [
    sops-nix.nixosModules.sops
  ];

  # , sops -a "$(cat key.pub | , ssh-to-age)" file.toml
  sops.defaultSopsFormat = "yaml";

  sops.age = {
    sshKeyPaths = [
      "${home}/.ssh/nixos-core"
      "${home}/.ssh/nixos-${hostName}"
    ]
    ++ (map (group: "${home}/.ssh/nixos-${group}") groups);
  };
}
