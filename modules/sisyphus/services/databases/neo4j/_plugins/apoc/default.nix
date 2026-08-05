{
  stdenv,
  lib,
  fetchurl,
}:

stdenv.mkDerivation rec {
  pname = "apoc";
  version = "2026.07.0";

  src = fetchurl {
    url = "https://github.com/neo4j/apoc/releases/download/${version}/apoc-${version}-core.jar";
    hash = "sha256-uyVCiFjIvsLc93LlAmkIFDkwPOUj4ZvTbGkBkrZQy2M=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p "$out/share/neo4j"
    cp $src "$out/share/neo4j"
  '';

  meta = with lib; {
    description = "Awesome Procedures for Neo4j.";
    homepage = "https://github.com/neo4j/apoc";
    license = licenses.asl20;
    maintainers = with maintainers; [ c2fc2f ];
    platforms = platforms.unix;
  };
}
