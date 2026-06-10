{
  stdenv,
  lib,
  fetchurl,
}:

stdenv.mkDerivation rec {
  pname = "fleet-management";
  version = "1.2.0";

  src = fetchurl {
    url = "https://dist.neo4j.org/fleet-management/${version}/neo4j-fleet-management-plugin-${version}-v2025.jar";
    hash = "sha256-5MMlCmC6PPNBxgVzyKwgI3epOoL2IXLZTKbMVGIiL68=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p "$out/share/neo4j"
    cp $src "$out/share/neo4j"
  '';

  meta = with lib; {
    description = "Manage, monitor, and optimize your Neo4j deployments from one control plane — cloud, on-prem, or hybrid. Get real-time visibility, automate operations, and improve performance across environments.";
    homepage = "https://github.com/neo4j-labs/neosemantics";
    license = licenses.asl20;
    maintainers = with maintainers; [ c2fc2f ];
    platforms = platforms.unix;
  };
}
