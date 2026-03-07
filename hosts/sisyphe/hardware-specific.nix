{
  boot.swraid = {
    enable = true;
    mdadmConf = ''
      ARRAY /dev/md0 metadata=1.2 UUID=940fbd14:461cea16:c1c25c6f:67a97efc
      ARRAY /dev/md1 metadata=1.2 UUID=ada8290d:e8e0a062:33381635:1ab2b4fe
      MAILADDR mdadm-error@sagbot.com
    '';
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
}
