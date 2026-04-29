let
  addr = "127.0.0.84:8404";
in
{
  services.prometheus = rec {
    enable = true;

    exporters = {
      node = {
        enable = true;

        listenAddress = "127.0.0.1";
        port = 9000;

        enabledCollectors = [ "systemd" ];
        extraFlags = [
          "--collector.ethtool"
          "--collector.tcpstat"
        ];
      };
    };

    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [
              "${exporters.node.listenAddress}:${toString exporters.node.port}"
            ];
          }
        ];
      }
      {
        job_name = "haproxy";
        static_configs = [ { targets = [ addr ]; } ];
      }
    ];
  };

  custom.services.haproxy.frontends = [
    {
      name = "local_stats";
      bind = addr;
      mode = "http";
      extraConfig = "http-request use-service prometheus-exporter";
    }
  ];
}
