{
  stdenv,
  lib,
  fetchurl,
}:

stdenv.mkDerivation rec {
  pname = "neosemantics";
  version = "5.26.0";

  src = fetchurl {
    url = "https://github.com/neo4j-labs/neosemantics/releases/download/${version}/neosemantics-${version}.jar";
    hash = "sha256-UJvsGSvvzmIkp+O/eKDmt0rri/Yet6HgCbe2Lgc3kAs=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p "$out/share/neo4j"
    cp $src "$out/share/neo4j"
  '';

  meta = with lib; {
    description = "Neosemantics is a plugin that enables the use of RDF in Neo4j.";
    homepage = "https://github.com/neo4j-labs/neosemantics";
    license = licenses.asl20;
    maintainers = with maintainers; [ c2fc2f ];
    platforms = platforms.unix;
  };
}
