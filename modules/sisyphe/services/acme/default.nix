{ config, rootDomain, ... }:

{
  security.acme = {
    acceptTerms = true;

    defaults = {
      email = "acme@${rootDomain}";
      credentialFiles = {
        "CLOUDFLARE_DNS_API_TOKEN_FILE" =
          config.sops.secrets."cloudflare/dns-api-token".path;
      };
      dnsResolver = "1.1.1.1:53";
      enableDebugLogs = true;
    };

    certs = {
      atacc-edu = {
        domain = "atacc-edu.org";
        extraDomainNames = [ "*.atacc-edu.org" ];
        dnsProvider = "cloudflare";
      };
      atacc = {
        domain = "atacc.org";
        extraDomainNames = [ "*.atacc.org" ];
        dnsProvider = "cloudflare";
      };
    };
  };
}
