{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    arduino-nix.url = "github:bouk/arduino-nix";
    arduino-index = {
      url = "github:bouk/arduino-indexes";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      arduino-nix,
      arduino-index,
      ...
    }:
    let
      overlays = [
        arduino-nix.overlay
        (arduino-nix.mkArduinoPackageOverlay (
          arduino-index + "/index/package_index.json"
        ))
        (arduino-nix.mkArduinoLibraryOverlay (
          arduino-index + "/index/library_index.json"
        ))
      ];
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = (import nixpkgs) {
          inherit system overlays;
        };
      in
      rec {
        inherit pkgs;
        packages.arduino-cli = pkgs.wrapArduinoCLI {
          libraries = # with pkgs.arduinoLibraries;
            [
              # (arduino-nix.latestVersion Keyboard)
            ];

          packages =
            let
              inherit (pkgs.arduinoPackages) platforms;
              latestVersion = builtins.head (
                builtins.sort (a: b: a > b) (builtins.attrNames platforms.arduino.avr)
              );
            in
            [
              platforms.arduino.avr.${latestVersion}
            ];
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            packages.arduino-cli
          ];
        };
      }
    );
}
