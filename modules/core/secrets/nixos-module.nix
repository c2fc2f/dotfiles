{
  username,
  hostName,
  groups,
  config,
  lib,
  ...
}:
let
  cfg = config.custom.secrets;

  names = [
    "core"
    hostName
  ]
  ++ groups;

  inherit (config.users.users.${username}) home;
  inherit (lib) mkOption;
  inherit (lib) mkEnableOption;
  inherit (lib) mkMerge;
  inherit (lib) mkIf;
  inherit (lib) genAttrs;
  inherit (lib) types;

in
{
  options.custom.secrets = genAttrs names (name: {
    enable = mkEnableOption "age secret decryption for the '${name}' scope";

    keys = mkOption {
      type = types.listOf types.path;
      default = [ "${home}/.ssh/nixos-${name}" ];
      example = [ "/etc/ssh/ssh_host_ed25519_key" ];
      description = ''
        A list of SSH key paths used by sops-nix to decrypt secrets associated
        with the '${name}' identity.
      '';
    };
  });

  config = mkMerge (
    map (
      name:
      mkIf (cfg.${name}.enable or false) {
        sops.age.sshKeyPaths = cfg.${name}.keys;
      }
    ) names
  );
}
