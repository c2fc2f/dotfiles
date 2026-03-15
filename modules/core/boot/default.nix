{
  pkgs,
  lib,
  ...
}:

{
  boot = {
    # Console log level (0 = disabled)
    consoleLogLevel = 0;

    # Set a timeout of 0 seconds before booting the system
    loader.timeout = lib.mkDefault 0;

    kernelParams = [
      # Reduce kernel output during boot
      "quiet"

      # Enable graphical boot screen (via Plymouth)
      "splash"

      # Disable automatic USB device suspension
      "usbcore.autosuspend=-1"
    ];

    initrd = {
      # Disable verbose output for the initramfs
      verbose = false;

      systemd = {
        enable = true;

        extraBin.setleds = "${pkgs.kbd}/bin/setleds";

        # Run commands before devices are initialized
        # Enable Num Lock on all TTYs
        services.initrd-numlock = {
          description = "Enable Num Lock";

          wantedBy = [ "cryptsetup.target" ];
          before = [ "cryptsetup.target" ];

          unitConfig.DefaultDependencies = false;

          serviceConfig = {
            Type = "oneshot";

            StandardOutput = "journal+console";
            StandardError = "journal+console";

            ExecStart = "/bin/sh -c 'for tty in /dev/tty[1-6]; do /bin/setleds -D +num < $tty || true; done'";
          };
        };
      };
    };
  };
}
