final: prev:
let
  spotx = prev.fetchurl {
    url = "https://raw.githubusercontent.com/SpotX-Official/SpotX-Bash/refs/heads/main/spotx.sh";
    hash = "sha256-/p6cJKzaZzjcLJISFudstQjs+lPXnXx4f0vxKbF9Sqw=";
  };
in
{
  spotify = prev.spotify.overrideAttrs (old: {
    nativeBuildInputs =
      old.nativeBuildInputs
      ++ (with prev; [
        util-linux
        perl
        unzip
        zip
        curl
      ]);

    unpackPhase =
      builtins.replaceStrings
        [ "runHook postUnpack" ]
        [
          ''
            patchShebangs --build ${spotx}
            runHook postUnpack
          ''
        ]
        old.unpackPhase;

    installPhase =
      builtins.replaceStrings
        [ "runHook postInstall" ]
        [
          ''
            bash ${spotx} -f -P "$out/share/spotify"
            runHook postInstall
          ''
        ]
        old.installPhase;
  });
}
