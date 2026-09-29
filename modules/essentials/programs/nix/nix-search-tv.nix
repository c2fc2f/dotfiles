{ pkgs, username, ... }:

{
  home-manager.users.${username} = {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "ns";
        runtimeInputs = with pkgs; [
          fzf
          nix-search-tv
        ];
        text = ''exec "${pkgs.nix-search-tv.src}/nixpkgs.sh" "$@"'';
      })
    ];
  };
}
