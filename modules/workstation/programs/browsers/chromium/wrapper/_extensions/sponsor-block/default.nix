{
  stdenv,
  fetchzip,
  lib,
}:

stdenv.mkDerivation rec {
  pname = "sponsor-block-chromium";
  version = "6.1.7";

  src = fetchzip {
    url = "https://github.com/ajayyy/SponsorBlock/releases/download/${version}/ChromeExtension.zip";
    hash = "sha256-Frlh9G6BFvNe5UsO5jnK1qReaNU9RZKay7w4wOdvUY0=";
    stripRoot = false;
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -R . $out/
  '';

  meta = with lib; {
    description = "Skip YouTube video sponsors for Chromium";
    homepage = "https://github.com/ajayyy/SponsorBlock";
    license = licenses.gpl3;
    platforms = platforms.all;
  };
}
