{
  stdenv,
  fetchzip,
  lib,
}:

stdenv.mkDerivation rec {
  pname = "ublock-origin-chromium";
  version = "1.77.1b2";

  src = fetchzip {
    url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
    hash = "sha256-cf+cAMGTCjYYOgrHVE57tT7HeH0+xueARjl7kxGLcRg=";
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
