{
  custom.vpn.servers.sisyphus = {
    address = {
      public = {
        ipv6 = "2001:41d0:1004:2666::";
        ipv4 = "51.255.74.102";
      };
      private = {
        ipv6 = "fd03:82c3:601f::";
        ipv4 = "10.3.0.";
      };
    };

    firewallMarks = {
      outgoing = 42;
      force = 33;
    };

    RouteTable = 1000;

    serverPublicKey = "cVVzjCOiJ+IDQhYEdgD6KfQk21XSvuWet48riugHCgs=";

    publicNetworkInterface = "enp6s0";
  };
}
