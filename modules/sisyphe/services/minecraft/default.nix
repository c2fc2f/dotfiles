{ nix-minecraft, ... }:

{
  imports = [
    # keep-sorted start
    nix-minecraft.nixosModules.minecraft-servers
    ./beyond_ascension.nix
    # keep-sorted end
  ];
  nixpkgs.overlays = [
    nix-minecraft.overlay
  ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
  };
}
