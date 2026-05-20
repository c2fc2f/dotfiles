{ pkgs, ... }:

{
  boot.initrd.systemd = {
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
}
