{
  systemd = {
    network.wait-online.enable = false;
    services.NetworkManager-wait-online.enable = false;
  };
  boot.initrd.systemd.network.wait-online.enable = false;
}
