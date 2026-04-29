{ config, mainDomain, ... }:

{
  security.acme = {
    acceptTerms = true;

    defaults = {
      email = "acme@${mainDomain}";
      credentialFiles = {
        "CLOUDFLARE_DNS_API_TOKEN_FILE" =
          config.sops.secrets."cloudflare/dns-api-token".path;
      };
    };

    certs = {
      ${mainDomain} = {
        domain = mainDomain;
        extraDomainNames = [ "*.${mainDomain}" ];
        dnsProvider = "cloudflare";
      };

      "atacc-edu.org" = {
        domain = "atacc-edu.org";
        extraDomainNames = [ "*.atacc-edu.org" ];
        dnsProvider = "cloudflare";
      };

      "culottes.org" = {
        domain = "culottes.org";
        extraDomainNames = [ "*.culottes.org" ];
        dnsProvider = "cloudflare";
      };

      "c2fc2f.com" = {
        domain = "c2fc2f.com";
        extraDomainNames = [ "*.c2fc2f.com" ];
        dnsProvider = "cloudflare";
      };

      "kill-yourself.fr" = {
        domain = "kill-yourself.fr";
        extraDomainNames = [ "*.kill-yourself.fr" ];
        dnsProvider = "cloudflare";
      };
    };
  };
}
