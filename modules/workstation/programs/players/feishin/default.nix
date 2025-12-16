{ pkgs, username, ... }:

{
  home-manager.users.${username} = {
    home.packages = [
      (pkgs.feishin.overrideAttrs (old: rec {
        version = "1.0.1-beta.1";

        src = pkgs.fetchzip {
          url = "https://github.com/jeffvli/feishin/archive/refs/tags/v${version}.tar.gz";
          sha256 = "sha256-8A5rnU2YyGnTuWQv/xOIGkbwsUkAkn4hlWUXFGRcPDk=";
        };

        pnpmDeps = pkgs.pnpm.fetchDeps {
          inherit version src;
          inherit (old) pname;
          fetcherVersion = 2;
          hash = "sha256-uRUql+jrZO/apmGNazjnIyGisufOLr5hAB9M/2q74i8=";
        };
      }))
    ];
  };
}
