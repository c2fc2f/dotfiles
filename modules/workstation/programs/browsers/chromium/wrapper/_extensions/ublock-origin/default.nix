{
  stdenv,
  fetchzip,
  lib,
}:

stdenv.mkDerivation rec {
  pname = "ublock-origin-chromium";
  version = "1.76.3b1";

  src = fetchzip {
    url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
    hash = "sha256-TJc/5kDFcBbT8gKVk1kA/E/IjbBG10+2s5+TCFHUSNI=";
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
