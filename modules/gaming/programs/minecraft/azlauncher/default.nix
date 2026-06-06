{ pkgs, username, ... }: {
  nixpkgs.overlays = [ (import ./_overlay.nix) ];

  home-manager.users.${username} = {
    home.packages = [ pkgs.custom.azlauncher ];
  };
}
