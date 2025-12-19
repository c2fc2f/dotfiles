{ nix-minecraft, ... }:

{
  imports = [
    # keep-sorted start
    nix-minecraft.nixosModules.minecraft-servers
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
