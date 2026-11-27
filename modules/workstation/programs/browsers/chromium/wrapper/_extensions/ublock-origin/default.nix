{
  stdenv,
  fetchzip,
  lib,
}:

stdenv.mkDerivation rec {
  pname = "ublock-origin-chromium";
  version = "1.77.4";

  src = fetchzip {
    url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
    hash = "sha256-9gmgWIp3ngdmMUY/H9FvQNYk8Bk+F4nDYHdNO1/79fY=";
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
