{
  stdenv,
  lib,
  fetchurl,
}:

stdenv.mkDerivation rec {
  pname = "apoc";
  version = "5.26.27";

  src = fetchurl {
    url = "https://github.com/neo4j/apoc/releases/download/${version}/apoc-${version}-core.jar";
    hash = "sha256-WbsqQjds08jFTM3YBOuXS8cUOWVqujKPpyTk9lp9FJI=";
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
