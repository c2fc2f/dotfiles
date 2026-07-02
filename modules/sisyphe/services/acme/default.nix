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
      atacc = {
        domain = "atacc-edu.org";
        extraDomainNames = [ "*.atacc-edu.org" ];
        dnsProvider = "cloudflare";
      };
    };
  };
}
