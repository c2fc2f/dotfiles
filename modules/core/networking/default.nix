{
  hostName,
  config,
  lib,
  ...
}:

{
  networking = {
    inherit hostName;

    useNetworkd = true;
    useDHCP = lib.mkForce false;
    dhcpcd.enable = false;
    enableIPv6 = true;

    networkmanager = {
      enable = true;

      unmanaged = lib.mapAttrsToList (_: value: value.matchConfig.Name) config.systemd.network.networks;
    };
  };

  systemd.network.enable = true;
}
