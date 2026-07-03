{
  config,
  pkgs,
  lib,
  clib,
  rootDomain,
  ...
}:
let
  certDir = config.security.acme.certs.${toString rootDomain}.directory;

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

  ncNotifyScript = pkgs.writeShellApplication {
    name = "nc-mail-notify";
    runtimeInputs = [ config.services.nextcloud.occ ];
    text = ''
      TO="$1"
      FROM="$2"
      SUBJECT="$3"

      CN="''${TO%@*}"

      /run/wrappers/bin/sudo < /dev/null \
        nextcloud-occ notification:generate \
        "$CN" \
        "New e-mail from $FROM" \
        -l "$SUBJECT" > /dev/null || true
    '';
  };
in
{
  services.dovecot2 = {
    enable = true;

    createMailUser = false;

    settings = {
      protocols = {
        imap = true;
        lmtp = true;
        sieve = true;
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

      "protocol lmtp" = {
        mail_plugins = {
          "sieve" = true;
        };
      };

      sieve_plugins = {
        sieve_extprograms = true;
      };
      sieve_global_extensions = {
        "vnd.dovecot.execute" = true;
      };
      sieve_execute_bin_dir = "${ncNotifyScript}/bin";

      "sieve_script before" = {
        type = "before";

        path = pkgs.writeTextDir "notify.sieve" ''
          require [
            "variables",
            "envelope",
            "vnd.dovecot.execute"
          ];

          if envelope :matches "to" "*" { set "to" "''${1}"; }
          if header :matches "from" "*" { set "from" "''${1}"; }
          if header :matches "subject" "*" { set "subject" "''${1}"; }

          execute "nc-mail-notify" [
            "''${to}",
            "''${from}",
            "''${subject}"
          ];
        '';
      };

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
      ldap_base = "ou=users,dc=${rootDomain.sld},dc=${rootDomain.tld}";
      ldap_scope = "subtree";
      ldap_auth_dn = "cn=readonly,dc=${rootDomain.sld},dc=${rootDomain.tld}";
      ldap_auth_dn_password = "<${
        config.sops.secrets."openldap/readonly/password".path
      }";
      ldap_version = 3;

      "passdb ldap" = {
        driver = "ldap";

        ldap_bind = true;
        bind_userdn = clib.rmNewline ''
          cn=%{user},
          ou=users,
          dc=${rootDomain.sld},
          dc=${rootDomain.tld}
        '';

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

  environment.systemPackages = [ pkgs.dovecot_pigeonhole ];

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

  security.sudo.extraRules = [
    {
      users = [ "vmail" ];
      commands = [
        {
          command = lib.getExe config.services.nextcloud.occ;
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  security.acme.defaults.reloadServices = [ "dovecot" ];

  networking.firewall.allowedTCPPorts = [
    143 # IMAP (STARTTLS)
    993 # IMAPS
  ];
}
