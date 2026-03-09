{
  config,
  mainDomain,
  ...
}:

{
  services.postfix = {
    enable = true;

    settings.main = {
      myhostname = "mail.y3.rs";
      mydestination = "localhost.$mydomain, localhost";

      queue_directory = "/var/spool/postfix";

      virtual_mailbox_domains = "y3.rs, ${mainDomain}";
      virtual_transport = "lmtp:unix:private/dovecot-lmtp";

      smtpd_sasl_type = "dovecot";
      smtpd_sasl_path = "private/auth";
      smtpd_sasl_auth_enable = "yes";
      smtpd_sasl_security_options = "noanonymous";
      smtpd_sasl_local_domain = "$myhostname";
      broken_sasl_auth_clients = "yes";

      smtpd_tls_cert_file = "${./assets/server.crt}";
      smtpd_tls_key_file =
        let
          inherit (config.sops) secrets;
        in
        "${secrets."dovecot/server/sslKey".path}";
      smtpd_tls_security_level = "may";

      smtpd_recipient_restrictions = [
        "permit_sasl_authenticated"
        "permit_mynetworks"
        "reject_unauth_destination"
      ];
    };

    virtual = ''
      @y3.rs contact@${mainDomain}
    '';
  };

  networking.firewall.allowedTCPPorts = [
    25
    465
  ];
}
