{
  config,
  pkgs,
  lib,
  clib,
  mainDomain,
  ...
}:
let
  splitDomain = lib.splitString "." mainDomain;
  tld = builtins.elemAt splitDomain 1;
  domain = builtins.elemAt splitDomain 0;

  certDir = config.security.acme.certs.${mainDomain}.directory;

  user = {
    uid = 5000;
    description = "Virtual mail user";
    isSystemUser = true;

    group = "vmail";

    home = "/var/vmail";
    createHome = true;
  };

  version =
    let
      version = "2.4.4";
    in
    lib.warnIf (pkgs.dovecot.version != version) ''
      dovecot2 (v${pkgs.dovecot.version}) but targets v${version} review:
      - dovecot_config_version
      - dovecot_storage_version
    '' version;
in
{
  services.dovecot2 = {
    enable = true;

    createMailUser = false;

    settings = {
      protocols = {
        imap = true;
        lmtp = true;
      };

      ssl = "required";

      mail_uid = user.uid;
      mail_gid = user.uid;

      mail_driver = "maildir";
      mail_home = "${user.home}/%{user | username | lower}";
      mail_path = "~/mail";

      ssl_server_ca_file = "${certDir}/chain.pem";
      ssl_server_cert_file = "${certDir}/fullchain.pem";
      ssl_server_key_file = "${certDir}/key.pem";

      log_debug = "category=auth";
      auth_verbose = true;

      auth_mechanisms = [
        "plain"
        "login"
      ];

      "service lmtp" = {
        "unix_listener /var/lib/postfix/dovecot-lmtp" = {
          mode = "0660";
          inherit (config.services.postfix) user group;
        };
      };

      "service auth" = {
        "unix_listener /var/lib/postfix/queue/private/auth" = {
          mode = "0660";
          inherit (config.services.postfix) user group;
        };
      };

      auth_username_format = "%{user | username | lower}";

      ldap_uris = "ldap://localhost";
      ldap_base = "ou=users,dc=${domain},dc=${tld}";
      ldap_scope = "subtree";
      ldap_auth_dn = "cn=readonly,dc=${domain},dc=${tld}";
      ldap_auth_dn_password = "<${
        config.sops.secrets."openldap/readonly/password".path
      }";
      ldap_version = 3;

      "passdb ldap" = {
        driver = "ldap";

        ldap_bind = true;
        bind_userdn = "cn=%{user},ou=users,dc=${domain},dc=${tld}";

        ldap_filter = clib.rmNewline ''
          (&(objectClass=inetLocalMailRecipient)
          (uid=%{user | lower}))
        '';
      };

      "userdb ldap" = {
        driver = "ldap";

        ldap_filter = clib.rmNewline ''
          (&(objectClass=inetLocalMailRecipient)
          (uid=%{user | lower}))
        '';
      };

      "namespace INBOX" = {
        inbox = true;

        "mailbox Archive" = {
          special_use = "\\Archive";
          auto = "subscribe";
        };

        "mailbox Drafts" = {
          special_use = "\\Drafts";
          auto = "subscribe";
        };

        "mailbox Junk" = {
          special_use = "\\Junk";
          auto = "subscribe";
        };

        "mailbox Sent" = {
          special_use = "\\Sent";
          auto = "subscribe";
        };

        "mailbox Trash" = {
          special_use = "\\Trash";
          auto = "subscribe";
        };
      };

      dovecot_config_version = version;
      dovecot_storage_version = version;
    };
  };

  users = {
    groups = {
      vmail = {
        gid = user.uid;
      };

      acme.members = [
        config.services.dovecot2.settings.default_internal_user
        "vmail"
      ];
      openldap.members = [
        config.services.dovecot2.settings.default_internal_user
      ];
    };

    users.vmail = user;
  };

  security.acme.defaults.reloadServices = [ "dovecot" ];

  networking.firewall.allowedTCPPorts = [
    143 # IMAP (STARTTLS)
    993 # IMAPS
  ];
}
