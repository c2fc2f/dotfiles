{
  lib,
  username,
  builders,
  rootDomain,
  ...
}:

{
  nix = {
    distributedBuilds = true;
    buildMachines = lib.imap0 (idx: builder: {
      hostName = "${builder}.${rootDomain}";
      system = "x86_64-linux";
      protocol = "ssh-ng";
      sshUser = username;

      maxJobs = 16;
      speedFactor = if idx == 0 then 2 else 1;

      supportedFeatures = [
        "kvm"
        "big-parallel"
        "nixos-test"
        "benchmark"
      ];
      mandatoryFeatures = [ ];
    }) builders;
  };
}
