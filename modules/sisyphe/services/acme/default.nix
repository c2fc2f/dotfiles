{ config, rootDomain, ... }:

{
  security.acme = {
    acceptTerms = true;
    defaults.email = "acme@${rootDomain}";
    defaults.credentialFiles = {
      "CLOUDFLARE_DNS_API_TOKEN_FILE" =
        config.sops.secrets."cloudflare/dns-api-token".path;
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
