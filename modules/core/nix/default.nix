{ username, ... }:

{
  imports = [
    # keep-sorted start
    ./settings.nix
    # keep-sorted end
  ];

  system.stateVersion = "26.05";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  home-manager.users.${username} = {
    home.stateVersion = "26.05";
  };
}
