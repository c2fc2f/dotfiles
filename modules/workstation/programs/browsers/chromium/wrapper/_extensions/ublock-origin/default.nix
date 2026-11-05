{
  stdenv,
  fetchzip,
  lib,
}:

stdenv.mkDerivation rec {
  pname = "ublock-origin-chromium";
  version = "1.75.5rc4";

  src = fetchzip {
    url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
    hash = "sha256-XTF2I6phh74FPr+jJvKOn0rbz2rzawr5sRpqxHZWGbY=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -R . $out/
  '';

  meta = with lib; {
    description = "An efficient blocker for Chromium";
    homepage = "https://github.com/gorhill/uBlock";
    license = licenses.gpl3;
    platforms = platforms.all;
  };
}
