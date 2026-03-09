{
  config,
  ...
}:

{
  users.users.vmail = {
    isSystemUser = true;
    group = "vmail";
    uid = 5000;
    home = "/var/vmail";
    createHome = true;
  };

  users.groups.vmail = {
    gid = 5000;
  };

  services.dovecot2 = {
    enable = true;

    createMailUser = true;

    sslCACert = "${../assets/ca.crt}";
    sslServerCert = "${../assets/server.crt}";
    sslServerKey = "${config.sops.secrets."dovecot/server/sslKey".path}";

    enableImap = true;
    enablePop3 = false;
    enableQuota = false;

    mailboxes = {
      Inbox = {
        auto = "subscribe";
      };
      Drafts = {
        specialUse = "Drafts";
        auto = "subscribe";
      };
      Sent = {
        specialUse = "Sent";
        auto = "subscribe";
      };
      Junk = {
        specialUse = "Junk";
        auto = "subscribe";
      };
      Trash = {
        specialUse = "Trash";
        auto = "subscribe";
      };
    };

    protocols = [
      "lmtp"
    ];

    extraConfig = ''
      protocols = $protocols lmtp

      service lmtp {
        unix_listener /var/spool/postfix/private/dovecot-lmtp {
          mode = 0660
          user = postfix
          group = postfix
        }
      }

      service auth {
        unix_listener /var/spool/postfix/private/auth {
          mode = 0660
          user = postfix
          group = postfix
        }
      }

      userdb {
        driver = static
        args = uid=vmail gid=vmail home=/var/vmail/%d/%n
      }

      passdb {
        driver = oauth2
        mechanisms = xoauth2 oauthbearer
        args = ${config.sops.templates."dovecot-oauth2.conf".path}
      }

      auth_mechanisms = xoauth2 oauthbearer
    '';
  };

  sops.templates."dovecot-oauth2.conf" = {
    content =
      let
        inherit (config.sops) placeholder;
      in
      ''
        introspection_url = ${placeholder."dovecot/introspection_url"}
        client_id = dovecot-test
        client_secret = ${placeholder."dovecot/client_secret"}
        active_attribute = active
        active_value = true
      '';

    owner = config.services.dovecot2.user;
    inherit (config.services.dovecot2) group;
    mode = "0400";
  };

  networking.firewall.allowedTCPPorts = [
    143
    993
  ];
}
