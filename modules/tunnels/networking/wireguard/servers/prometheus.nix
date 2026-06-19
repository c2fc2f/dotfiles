{
  custom.vpn.servers.prometheus = {
    address = {
      public = {
        ipv4 = "185.224.129.103";
      };
      private = {
        ipv4 = "10.9.0.";
      };
    };

    firewallMarks = {
      outgoing = 82;
      force = 55;
    };

    RouteTable = 3000;

    serverPublicKey = "l9LJD5LVp9gp6GgvBJSqf/nV0NwR4oXB3IZTfD1byHA=";

    publicNetworkInterface = "ens3";
  };
}
