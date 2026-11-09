{
  stdenv,
  fetchzip,
  lib,
}:

stdenv.mkDerivation rec {
  pname = "ublock-origin-chromium";
  version = "1.76.1b0";

  src = fetchzip {
    url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
    hash = "sha256-Dfnlb1QzGA0UG1f6YU9hOkcPDQsbe2/bKXy24K4U0y8=";
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
