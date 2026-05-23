{
  lib,
  config,
  hostName,
  mainDomain,
  ...
}:
let
  splitDomain = lib.splitString "." mainDomain;
  tld = builtins.elemAt splitDomain 1;
  domain = builtins.elemAt splitDomain 0;
in
{
  services.postfix = {
    enable = true;
    enableSmtp = true;
    enableSubmission = true;
    enableSubmissions = true;

    settings = {
      main = {
        mydomain = mainDomain;
        myhostname = "${hostName}.${mainDomain}";
        mynetworks = [
          "127.0.0.0/8"
          "[::1]/128"
          "193.52.159.57/32"
        ];

        smtpd_sasl_type = "dovecot";
        smtpd_sasl_path = "private/auth";
        smtpd_sasl_auth_enable = "yes";
        smtpd_sasl_security_options = "noanonymous";

        virtual_alias_maps = "ldap:${
          config.sops.templates."postfix-ldap-aliases.cf".path
        }";
        virtual_mailbox_maps = "ldap:${
          config.sops.templates."postfix-ldap-users.cf".path
        }";

        virtual_transport = "lmtp:unix:/var/lib/postfix/dovecot-lmtp";
        mailbox_transport = "lmtp:unix:/var/lib/postfix/dovecot-lmtp";

        smtpd_relay_restrictions = [
          "permit_sasl_authenticated"
          "permit_mynetworks"
          "reject_unauth_destination"
        ];

        virtual_mailbox_domains = map (cert: cert.domain) (
          builtins.attrValues config.security.acme.certs
        );

        smtpd_tls_chain_files =
          let
            certDir = config.security.acme.certs.${mainDomain}.directory;
          in
          [
            "${certDir}/key.pem"
            "${certDir}/fullchain.pem"
          ];
      };
    };
  };

  sops.templates."postfix-ldap-aliases.cf" = {
    content = ''
      server_host = ldap://localhost
      search_base = ou=users,dc=${domain},dc=${tld}
      version = 3

      query_filter = (&(objectClass=inetLocalMailRecipient)(|(mail=%s)(mailLocalAddress=%s)(mailLocalAddress=@%d)))

      result_attribute = mail 

      bind = yes
      bind_dn = cn=readonly,dc=${domain},dc=${tld}
      bind_pw = ${config.sops.placeholder."openldap/readonly/password"}
    '';

    owner = config.services.postfix.user;
  };

  sops.templates."postfix-ldap-users.cf" = {
    content = ''
      server_host = ldap://localhost
      search_base = ou=users,dc=${domain},dc=${tld}
      version = 3

      query_filter = (&(objectClass=inetLocalMailRecipient)(mail=%s))

      result_attribute = mail 

      bind = yes
      bind_dn = cn=readonly,dc=${domain},dc=${tld}
      bind_pw = ${config.sops.placeholder."openldap/readonly/password"}
    '';

    owner = config.services.postfix.user;
  };

  users.groups.acme.members = [ config.services.postfix.user ];
  security.acme.defaults.reloadServices = [ "postfix" ];

  networking.firewall.allowedTCPPorts = [
    25 # SMTP
    587 # Submission SMTP
    465 # Submission TLS SMTP
  ];
}
