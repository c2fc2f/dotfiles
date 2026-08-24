{
  description = "NixOS Configuration";

  inputs = {
    # keep-sorted start block=yes
    cliclicker = {
      url = "github:c2fc2f/cliclicker";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    focal = {
      url = "github:iynaix/focal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hermux = {
      url = "github:c2fc2f/hermux";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nh = {
      url = "github:nix-community/nh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:niri-wm/niri";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-wrapper = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs = {
      # url = "git+file:///home/c2fc2f/git/nixpkgs/";
      url = "github:nixos/nixpkgs";
    };
    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    opendeck-nix = {
      url = "github:Kitt3120/opendeck-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # keep-sorted end
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      systems,
      treefmt-nix,
      ...
    }@inputs:
    let
      username = "c2fc2f";
      hostHeader = "sisyphus";
      builders = [
        "sisyphus"
        "sisyphe"
      ];

      rootDomain = {
        sld = "sagbot";
        tld = "com";

        __toString = self: "${self.sld}.${self.tld}";
      };

      systemInfo = {
        # keep-sorted start block=yes
        icarus = {
          groups = [
            # keep-sorted start
            "server"
            "tunnels"
            # keep-sorted end
          ];
        };
        niobe = {
          groups = [
            # keep-sorted start
            "development"
            "gaming"
            "tunnels"
            "workstation"
            # keep-sorted end
          ];
        };
        prometheus = {
          groups = [
            # keep-sorted start
            "seedbox"
            "server"
            "tunnels"
            # keep-sorted end
          ];
        };
        sisyphe = {
          groups = [
            # keep-sorted start
            "server"
            # keep-sorted end
          ];
        };
        sisyphus = {
          groups = [
            # keep-sorted start
            "server"
            "tunnels"
            # keep-sorted end
          ];
        };
        tantalus = {
          groups = [
            # keep-sorted start
            "development"
            "laptop"
            "tunnels"
            "workstation"
            # keep-sorted end
          ];
        };
        # keep-sorted end
      };

      eachSystem =
        f:
        nixpkgs.lib.genAttrs (import systems) (
          system: f nixpkgs.legacyPackages.${system}
        );

      treefmtEval = eachSystem (
        pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix
      );

      clib =
        let
          inherit (nixpkgs) lib;
          entries = builtins.readDir ./lib;

          loadLibFunctions = lib.mapAttrs (
            name: type:
            if type == "directory" || type == "regular" then
              import (./lib + "/${name}") { inherit lib; }
            else
              null
          ) entries;

          validFunctions = lib.filterAttrs (
            _: value: value != null
          ) loadLibFunctions;
        in
        validFunctions;
    in
    {
      formatter = eachSystem (
        pkgs:
        treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.wrapper
      );
      checks = eachSystem (pkgs: {
        formatting =
          treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.check
            self;
      });

      nixosConfigurations = nixpkgs.lib.mapAttrs (
        hostName: entry:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit clib;
            inherit hostName;
            inherit systemInfo;
            inherit username;
            inherit hostHeader;
            inherit builders;
            inherit rootDomain;
          }
          // entry
          // inputs;
          modules = [
            ./hosts
            ./modules
            {
              nixpkgs.overlays = [
                (final: _: {
                  unstable = import nixpkgs-unstable {
                    inherit (final) config;
                    inherit (final.stdenv.hostPlatform) system;
                  };
                })
              ];
            }
          ];
        }
      ) systemInfo;
    };
}
