{ hostName, ... }:

{
  imports = [
    # keep-sorted start
    ./wait-online.nix
    # keep-sorted end
  ];

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
