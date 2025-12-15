{ pkgs, username, ... }:

{
  home-manager.users.${username} = {
    home.packages = [
      (pkgs.feishin.overrideAttrs (old: rec {
        version = "0.22.0";

        src = pkgs.fetchzip {
          url = "https://github.com/jeffvli/feishin/archive/refs/tags/v${version}.tar.gz";
          sha256 = "sha256-sRP89xgCl49WZ7A6KaQd/vJTIDvAfZuhRbL3mcBBnIg=";
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
