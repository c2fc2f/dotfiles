{
  callPackage,
}:

[
  "${callPackage ./neosemantics { }}/share/neo4j"
  "${callPackage ./apoc { }}/share/neo4j"
]
