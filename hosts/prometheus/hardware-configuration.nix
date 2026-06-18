{ lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot = {
    initrd = {
      availableKernelModules = [
        "ata_piix"
        "uhci_hcd"
        "virtio_pci"
        "sr_mod"
        "virtio_blk"
      ];
      kernelModules = [ ];

      luks = {
        devices = {
          "cryptroot" = {
            device = "/dev/disk/by-uuid/07c2369b-d819-410f-823c-2f670a78c1e6";
          };
        };
      };
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/mapper/cryptroot";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/b4bca405-4798-4808-9b58-81ba8a274a08";
      fsType = "ext4";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/3a0e2653-d004-451f-842a-7414d4f67b0f"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
