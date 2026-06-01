{ username, config, ... }:

{
  system.stateVersion = config.system.nixos.release;

  nixpkgs.config.allowUnfree = true;

  home-manager.users.${username} = {
    home.stateVersion = config.system.nixos.release;
  };
}
