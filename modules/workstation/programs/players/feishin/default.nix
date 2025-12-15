{ pkgs, username, ... }:

{
  home-manager.users.${username} = {
    home.packages = [
      (pkgs.feishin.overrideAttrs (old: rec {
        version = "1.0.0-beta.11";

        src = pkgs.fetchzip {
          url = "https://github.com/jeffvli/feishin/archive/refs/tags/v${version}.tar.gz";
          sha256 = "sha256-+cXQJ0qb0n08gn53vPqEpHg9t6mnOZgsE/H+LTc0SW4=";
        };

        pnpmDeps = pkgs.pnpm.fetchDeps {
          inherit version src;
          inherit (old) pname;
          fetcherVersion = 2;
          hash = "sha256-W+tnburrd0NdFxuRAZBgDAW8smiePjL7V/8phRik4A0=";
        };
      }))
    ];
  };
}
