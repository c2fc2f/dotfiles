{
  description = "Rust development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      fenix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        fenixPkgs = fenix.packages.${system};

        nightlyToolchain = fenixPkgs.complete.withComponents [
          "rustc"
          "cargo"
          "clippy"
          "rustfmt"
          "rust-analyzer"
        ];
      in
      {
        devShells.default = pkgs.mkShell rec {
          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs = [
            pkgs.clang
            pkgs.llvmPackages.bintools
            nightlyToolchain
          ];

          LIBCLANG_PATH = pkgs.lib.makeLibraryPath [
            pkgs.llvmPackages_latest.libclang.lib
          ];

          shellHook = ''
            echo "Using Rust nightly from fenix: $(rustc --version)"
          '';

          RUSTFLAGS = (
            builtins.map (a: "-L ${a}/lib") [
              # libs
            ]
          );
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (
            buildInputs ++ nativeBuildInputs
          );

          BINDGEN_EXTRA_CLANG_ARGS =
            (builtins.map (a: ''-I"${a}/include"'') [
              pkgs.glibc.dev
            ])
            ++ [
              ''-I"${pkgs.llvmPackages_latest.libclang.lib}/lib/clang/${pkgs.llvmPackages_latest.libclang.version}/include"''
              ''-I"${pkgs.glib.dev}/include/glib-2.0"''
              "-I${pkgs.glib.out}/lib/glib-2.0/include/"
            ];
        };
      }
    );
}
