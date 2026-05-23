{
  config,
  clib,
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

    overrides = {
      "rbl.conf".text = ''
        rbls {
          senderscore {
            enabled = false;
            disable_monitoring = true;
          }
        }
      '';
    };

    locals = {
      "options.inc".text = ''
        dns {
          nameserver = [
            "127.0.0.1:53", 
            "[::1]:53"
          ];
        }
      '';

      "rbl.conf".source = config.sops.templates."rbl.conf".path;
      "rbl_group.conf".source = ./config/rbl_group.conf;

      "actions.conf".text = ''
        reject = null;
        greylist = null;
        add_header = 6;
      '';

      "milter_headers.conf".text = ''
        use = [
          "x-spamd-result", 
          "x-rspamd-server", 
          "x-rspamd-queue-id"
        ];
        authenticated_headers = [ "x-spamd-result" ];
      '';

      "dkim_signing.conf".text = ''
        enabled = true;

        sign_authenticated = true;
        sign_local = true;
        sign_inbound = false;

        allow_username_mismatch = true;
        allow_hdrfrom_mismatch = true;

        domain {
        ${builtins.concatStringsSep "\n" (
          map (
            cert:
            clib.indent 2 ''
              ${cert.domain} {
                path = "${
                  config.sops.secrets."rspamd/dkim/${cert.domain}/key".path
                }";
                selector = "mail";
              }
            ''
          ) (builtins.attrValues config.security.acme.certs)
        )}
        }
      '';

      "redis.conf".text = ''
        servers = "${config.services.redis.servers.rspamd.unixSocket}";
      '';

      "classifier-bayes.conf".text = ''
        backend = "redis";
        autolearn = true;
      '';

      "worker-controller.inc".source =
        config.sops.templates."worker-controller.inc".path;
    };
  };

  sops.templates =
    let
      owner = config.services.rspamd.user;
    in
    {
      "worker-controller.inc" = {
        content = ''
          bind_socket = "${listenAddress}";
          password = "${config.sops.placeholder."rspamd/password"}";
          enable_password = "${config.sops.placeholder."rspamd/password"}";
        '';
        inherit owner;
      };

      "rbl.conf" = {
        content =
          let
            dqs = config.sops.placeholder."rspamd/spamhaus/dqs";
          in
          ''
            rbls {
              spamhaus {
                rbl = "${dqs}.zen.dq.spamhaus.net";
                from = false;
              }
              spamhaus_from {
                from = true;
                received = false;
                rbl = "${dqs}.zen.dq.spamhaus.net";
                returncodes {
                  SPAMHAUS_ZEN = [
                      "127.0.0.2",
                      "127.0.0.3",
                      "127.0.0.4",
                      "127.0.0.5",
                      "127.0.0.6",
                      "127.0.0.7",
                      "127.0.0.9",
                      "127.0.0.10",
                      "127.0.0.11"
                  ];
                }
              }
              spamhaus_authbl_received {
                rbl = "${dqs}.authbl.dq.spamhaus.net";
                from = false;
                received = true;
                ipv6 = true;
                returncodes {
                  SH_AUTHBL_RECEIVED = "127.0.0.20"
                }
              }
              spamhaus_dbl {
                rbl = "${dqs}.dbl.dq.spamhaus.net";
                helo = true;
                rdns = true;
                dkim = true;
                disable_monitoring = true;
                returncodes {
                  RBL_DBL_SPAM = "127.0.1.2";
                  RBL_DBL_PHISH = "127.0.1.4";
                  RBL_DBL_MALWARE = "127.0.1.5";
                  RBL_DBL_BOTNET = "127.0.1.6";
                  RBL_DBL_ABUSED_SPAM = "127.0.1.102";
                  RBL_DBL_ABUSED_PHISH = "127.0.1.104";
                  RBL_DBL_ABUSED_MALWARE = "127.0.1.105";
                  RBL_DBL_ABUSED_BOTNET = "127.0.1.106";
                  RBL_DBL_DONT_QUERY_IPS = "127.0.1.255";
                }
              }
              spamhaus_dbl_fullurls {
                ignore_defaults = true;
                no_ip = true;
                rbl = "${dqs}.dbl.dq.spamhaus.net";
                selector = 'urls:get_host'
                disable_monitoring = true;
                returncodes {
                  DBLABUSED_SPAM_FULLURLS = "127.0.1.102";
                  DBLABUSED_PHISH_FULLURLS = "127.0.1.104";
                  DBLABUSED_MALWARE_FULLURLS = "127.0.1.105";
                  DBLABUSED_BOTNET_FULLURLS = "127.0.1.106";
                }
              }
              spamhaus_zrd {
                rbl = "${dqs}.zrd.dq.spamhaus.net";
                helo = true;
                rdns = true;
                dkim = true;
                disable_monitoring = true;
                returncodes {
                  RBL_ZRD_VERY_FRESH_DOMAIN = [
                    "127.0.2.2",
                    "127.0.2.3",
                    "127.0.2.4"
                  ];
                  RBL_ZRD_FRESH_DOMAIN = [
                    "127.0.2.5",
                    "127.0.2.6",
                    "127.0.2.7",
                    "127.0.2.8",
                    "127.0.2.9",
                    "127.0.2.10",
                    "127.0.2.11",
                    "127.0.2.12",
                    "127.0.2.13",
                    "127.0.2.14",
                    "127.0.2.15",
                    "127.0.2.16",
                    "127.0.2.17",
                    "127.0.2.18",
                    "127.0.2.19",
                    "127.0.2.20",
                    "127.0.2.21",
                    "127.0.2.22",
                    "127.0.2.23",
                    "127.0.2.24"
                  ];
                  RBL_ZRD_DONT_QUERY_IPS = "127.0.2.255";
                }
              }
              "SPAMHAUS_ZEN_URIBL" {
                enabled = true;
                rbl = "${dqs}.zen.dq.spamhaus.net";
                resolve_ip = true;
                checks = ['urls'];
                replyto = true;
                emails = true;
                ipv4 = true;
                ipv6 = true;
                emails_domainonly = true;
                returncodes {
                  URIBL_SBL = "127.0.0.2";
                  URIBL_SBL_CSS = "127.0.0.3";
                  URIBL_XBL = [
                    "127.0.0.4",
                    "127.0.0.5",
                    "127.0.0.6",
                    "127.0.0.7"
                  ];
                  URIBL_PBL = [
                    "127.0.0.10",
                    "127.0.0.11"
                  ];
                  URIBL_DROP = "127.0.0.9";
                }
              }
              SH_EMAIL_DBL {
                ignore_defaults = true;
                replyto = true;
                emails_domainonly = true;
                disable_monitoring = true;
                rbl = "${dqs}.dbl.dq.spamhaus.net"
                returncodes = {
                  SH_EMAIL_DBL = [
                    "127.0.1.2",
                    "127.0.1.4",
                    "127.0.1.5",
                    "127.0.1.6"
                  ];
                  SH_EMAIL_DBL_ABUSED = [
                    "127.0.1.102",
                    "127.0.1.104",
                    "127.0.1.105",
                    "127.0.1.106"
                  ];
                  SH_EMAIL_DBL_DONT_QUERY_IPS = [ "127.0.1.255" ];
                }
              }
              SH_EMAIL_ZRD {
                ignore_defaults = true;
                replyto = true;
                emails_domainonly = true;
                disable_monitoring = true;
                rbl = "${dqs}.zrd.dq.spamhaus.net"
                returncodes = {
                  SH_EMAIL_ZRD_VERY_FRESH_DOMAIN = [
                    "127.0.2.2",
                    "127.0.2.3",
                    "127.0.2.4"
                  ];
                  SH_EMAIL_ZRD_FRESH_DOMAIN = [
                    "127.0.2.5",
                    "127.0.2.6",
                    "127.0.2.7",
                    "127.0.2.8",
                    "127.0.2.9",
                    "127.0.2.10",
                    "127.0.2.11",
                    "127.0.2.12",
                    "127.0.2.13",
                    "127.0.2.14",
                    "127.0.2.15",
                    "127.0.2.16",
                    "127.0.2.17",
                    "127.0.2.18",
                    "127.0.2.19",
                    "127.0.2.20",
                    "127.0.2.21",
                    "127.0.2.22",
                    "127.0.2.23",
                    "127.0.2.24"
                  ];
                  SH_EMAIL_ZRD_DONT_QUERY_IPS = [ "127.0.2.255" ];
                }
              }
              "DBL" {
                rbl = "${dqs}.dbl.dq.spamhaus.net";
                disable_monitoring = true;
              }
              "ZRD" {
                ignore_defaults = true;
                rbl = "${dqs}.zrd.dq.spamhaus.net";
                no_ip = true;
                dkim = true;
                emails = true;
                emails_domainonly = true;
                urls = true;
                returncodes = {
                  ZRD_VERY_FRESH_DOMAIN = [
                    "127.0.2.2",
                    "127.0.2.3",
                    "127.0.2.4"
                  ];
                  ZRD_FRESH_DOMAIN = [
                    "127.0.2.5",
                    "127.0.2.6",
                    "127.0.2.7",
                    "127.0.2.8",
                    "127.0.2.9",
                    "127.0.2.10",
                    "127.0.2.11",
                    "127.0.2.12",
                    "127.0.2.13",
                    "127.0.2.14",
                    "127.0.2.15",
                    "127.0.2.16",
                    "127.0.2.17",
                    "127.0.2.18",
                    "127.0.2.19",
                    "127.0.2.20",
                    "127.0.2.21",
                    "127.0.2.22",
                    "127.0.2.23",
                    "127.0.2.24"
                  ];
                }
              }
              spamhaus_sbl_url {
                ignore_defaults = true
                rbl = "${dqs}.sbl.dq.spamhaus.net";
                checks = ['urls'];
                disable_monitoring = true;
                returncodes {
                    SPAMHAUS_SBL_URL = "127.0.0.2";
                }
              }
              SH_HBL_EMAIL {
                ignore_defaults = true;
                rbl = "_email.${dqs}.hbl.dq.spamhaus.net";
                emails_domainonly = false;
                selector = "from('smtp').lower;from('mime').lower";
                ignore_whitelist = true;
                checks = ['emails', 'replyto'];
                hash = "sha1";
                returncodes = {
                  SH_HBL_EMAIL = [ "127.0.3.2" ];
                }
              }
              spamhaus_dqs_hbl {
                symbol = "HBL_FILE_UNKNOWN";
                rbl = "_file.${dqs}.hbl.dq.spamhaus.net.";
                selector = "attachments('rbase32', 'sha256')";
                ignore_whitelist = true;
                ignore_defaults = true;
                returncodes {
                  SH_HBL_FILE_MALICIOUS = "127.0.3.10";
                  SH_HBL_FILE_SUSPICIOUS = "127.0.3.15";
                }
              }
            }
          '';
        inherit owner;
      };
    };

  services.redis.servers.rspamd = {
    enable = true;

    port = 0;
    inherit (config.services.rspamd) user;
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
          url = "rspamd.${mainDomain}";
          backend = "rspamd";
        }
      ];
    };
  };
}
