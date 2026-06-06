{ hostName, lib, ... }:

{
  imports =
    (lib.optional (builtins.pathExists ./_assets/servers/${hostName}.nix) ./_server.nix)
    ++ (lib.optional (builtins.pathExists ./_assets/users/${hostName}.nix) ./_user.nix);
}
