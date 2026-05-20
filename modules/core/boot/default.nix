{ lib, ... }:

{
  boot = {
    # Console log level (0 = disabled)
    consoleLogLevel = 0;

    # Set a timeout of 0 seconds before booting the system
    loader.timeout = lib.mkDefault 0;

    kernelParams = [
      # Reduce kernel output during boot
      "quiet"

      # Disable automatic USB device suspension
      "usbcore.autosuspend=-1"
    ];

    initrd = {
      # Disable verbose output for the initramfs
      verbose = false;

      systemd.enable = true;
    };
  };
}
