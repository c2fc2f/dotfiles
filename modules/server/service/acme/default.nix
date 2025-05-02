{ config, ... }:

{
  security.acme = {
    acceptTerms = true;
    defaults.email = "acme@sagbot.com";
    defaults.credentialFiles = {
      "CLOUDFLARE_DNS_API_TOKEN_FILE" = config.sops.secrets."cloudflare/dns-api-token".path;
    };
    certs = {
      sagbot = {
        domain = "sagbot.com";
        extraDomainNames = [
          "*.sagbot.com"
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
    };
  };
}
