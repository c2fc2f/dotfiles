{ config, lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.custom.vpn = {
    users = mkOption {
      type = types.attrsOf (
        types.submodule (_: {
          options = {

            userPublicKey = mkOption {
              type = types.str;
              description = "The client's public key for VPN authentication.";
              example = "UMyyQiNWllI/JGuh+BF6MZCYzSIJwDxO4gUuG5DGW38=";
            };
            suffix = mkOption {
              type = types.str;
              description = "Suffix for the client's internal IP address.";
              example = "2";
            };
            routeEverything = mkOption {
              type = types.bool;
              default = true;
              description = "Whether to route all traffic through the VPN.";
            };
            alwaysUp = mkOption {
              type = types.bool;
              default = false;
              description = "Whether the VPN connection should persist on boot.";
            };
          };
        })
      );
      default = { };
      description = "Definitions for individual VPN users.";
    };

    servers = mkOption {
      type = types.attrsOf (
        types.submodule (_: {
          options = {
            address = {
              public = {
                ipv4 = mkOption {
                  type = types.str;
                  description = "The public IPv4 address of the VPN endpoint.";
                  example = "198.51.100.42";
                };
                ipv6 = mkOption {
                  type = types.nullOr types.str;
                  default = null;
                  description = "The optional public IPv6 address of the VPN endpoint.";
                  example = "2001:db8:85a3:8d3:1319:8a2e:370:7348";
                };
              };
              private = {
                ipv4 = mkOption {
                  type = types.str;
                  description = "The private IPv4 subnet or address used inside the VPN tunnel.";
                  example = "10.6.0.1";
                };
                ipv6 = mkOption {
                  type = types.nullOr types.str;
                  default = null;
                  description = "The optional private IPv6 subnet or address used inside the VPN tunnel.";
                  example = "fd7b:ec5f:565f::1";
                };
              };
            };

            firewallMarks = {
              force = mkOption {
                type = types.int;
                description = "The firewall mark assigned to packets to force them through this interface.";
                example = 1;
              };

              outgoing = mkOption {
                type = types.int;
                description = "Sets a firewall mark on outgoing WireGuard packets.";
                example = 1;
              };
            };

            RouteTable = mkOption {
              type = types.int;
              description = "Specifies the routing table ID to use for the WireGuard interface.";
              example = 100;
            };

            serverPublicKey = mkOption {
              type = types.str;
              description = "The Base64 encoded public key of the VPN server.";
              example = "K6yP0/5nLAnJalmYMLGRWX2xfUtb+H6bLaNctCBJg2E=";
            };

            publicNetworkInterface = mkOption {
              type = types.str;
              default = "eth0";
              description = "The physical network interface used to route VPN traffic.";
              example = "ens6";
            };
          };
        })
      );
      default = { };
      description = "Configuration for custom VPN endpoints.";
    };
  };

  config = {
    assertions = [
      {
        assertion =
          let
            marks = lib.flatten (
              lib.mapAttrsToList (
                _: v: builtins.attrValues v.firewallMarks
              ) config.custom.vpn.servers
            );
          in
          lib.unique marks == marks;
        message = "Duplicate 'firewallMarks.<name>' detected in custom.vpn configuration. Each VPN server must have a unique firewall mark.";
      }
      {
        assertion =
          let
            tables = lib.mapAttrsToList (
              _: v: v.RouteTable
            ) config.custom.vpn.servers;
          in
          lib.unique tables == tables;
        message = "Duplicate 'RouteTable' ID detected in custom.vpn configuration. Each VPN server must have a unique routing table ID.";
      }
      {
        assertion =
          let
            ips = lib.flatten (
              lib.mapAttrsToList (
                _: v:
                lib.filter (x: x != null) (builtins.attrValues v.address.private)
              ) config.custom.vpn.servers
            );
          in
          lib.unique ips == ips;
        message = "Duplicate private IP address detected in custom.vpn configuration. Each VPN server must have a unique private IP.";
      }
    ];
  };
}
