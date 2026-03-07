{
  config,
  mainDomain,
  ...
}:

{
  security.acme = {
    acceptTerms = true;
    defaults.email = "acme@${mainDomain}";
    defaults.credentialFiles = {
      "CLOUDFLARE_DNS_API_TOKEN_FILE" = config.sops.secrets."cloudflare/dns-api-token".path;
    };
    certs = {
      ${mainDomain} = rec {
        domain = mainDomain;
        extraDomainNames = [
          "*.${domain}"
        ];
        dnsProvider = "cloudflare";
        postRun = ''
          cp cert.pem /opt/mailcow-dockerized/data/assets/ssl/
          cp key.pem /opt/mailcow-dockerized/data/assets/ssl/
          cd /opt/mailcow-dockerized/ && docker compose down && docker compose up -d
        '';
      };

      atacc = {
        domain = "atacc-edu.org";
        extraDomainNames = [
          "*.atacc-edu.org"
        ];
        dnsProvider = "cloudflare";
      };

      culottes = {
        domain = "culottes.org";
        extraDomainNames = [
          "*.culottes.org"
        ];
        dnsProvider = "cloudflare";
      };

      c2fc2f = {
        domain = "c2fc2f.com";
        extraDomainNames = [
          "*.c2fc2f.com"
        ];
        dnsProvider = "cloudflare";
      };

      kill-yourself = {
        domain = "kill-yourself.fr";
        extraDomainNames = [
          "*.kill-yourself.fr"
        ];
        dnsProvider = "cloudflare";
      };
    };
  };
}
