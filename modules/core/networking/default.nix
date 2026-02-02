{
  hostName,
  ...
}:

{
  networking = {
    inherit hostName;

    enableIPv6 = true;
    networkmanager = {
      enable = true;

      ethernet = {
        macAddress = "random";
      };
    };
  };
}
