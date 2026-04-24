{
  config,
  mainDomain,
  ...
}:
let
  listenAddress = "127.0.0.113:11334";
in
{
  services.rspamd = {
    enable = true;

    postfix = {
      enable = true;
      config = {
        milter_default_action = "accept";
        milter_protocol = "6";

        non_smtpd_milters = [ "unix:/run/rspamd/rspamd-milter.sock" ];
        smtpd_milters = [ "unix:/run/rspamd/rspamd-milter.sock" ];
      };
    };

    locals = {
      "actions.conf" = {
        text = ''
          reject = 9999;
          greylist = 9999;
          add_header = 6;
        '';
      };

      "worker-controller.inc" = {
        source = config.sops.templates."worker-controller.inc".path;
      };
    };
  };

  sops.templates."worker-controller.inc" = {
    content = ''
      bind_socket = "${listenAddress}";
      password = "${config.sops.placeholder."rspamd/password"}";
    '';

    owner = config.services.rspamd.user;
  };

  custom.services.haproxy = {
    backends = [
      {
        name = "rspamd";
        mode = "http";
        servers = [
          {
            name = "server1";
            addr = listenAddress;
            check = true;
          }
        ];
        extraConfig = "http-request set-path %[path,regsub(^/rspamd/?,/)]";
      }
    ];

    maps = {
      url = [
        {
          url = "mail.${mainDomain}/rspamd";
          backend = "rspamd";
        }
      ];
    };
  };
}
