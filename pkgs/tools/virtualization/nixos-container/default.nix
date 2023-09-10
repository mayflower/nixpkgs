{ runCommand
, perl
, shadow
, util-linux
, configurationDirectory ? "/etc/nixos-containers"
, stateDirectory ? "/var/lib/nixos-containers"
, nixosTests
}:

runCommand "nixos-container" {
  src = ./nixos-container.pl;
  env = {
    perl = perl.withPackages (p: [ p.FileSlurp ]);
    su = "${shadow.su}/bin/su";
    utillinux = util-linux;

    inherit configurationDirectory stateDirectory;
  };

  passthru = {
    tests = {
      inherit (nixosTests)
        containers-imperative
        containers-ip
        containers-tmpfs
        containers-ephemeral
        containers-unified-hierarchy
        ;
    };
  };
}
''
  t=$out/share/bash-completion/completions
  mkdir -p $t
  cp ${./nixos-container-completion.sh} $t/nixos-container
''
