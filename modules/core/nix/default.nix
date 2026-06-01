{ username, ... }:

{
  system.stateVersion = "26.11";

  nixpkgs.config.allowUnfree = true;

  home-manager.users.${username} = {
    home.stateVersion = "26.11";
  };
}
