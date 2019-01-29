# Miscellaneous small tests that don't warrant their own VM run.

import ./make-test.nix ({ pkgs, ...} : rec {
  name = "privacyidea";
  meta = with pkgs.stdenv.lib.maintainers; {
    maintainers = [ fpletz ];
  };

  machine = { ... }: {
    services.privacyidea = {
      enable = true;
      secretKey = "testing";
      pepper = "testing";
      adminPassword = "testing";
      adminEmail = "root@localhost";
    };
    services.nginx = {
      enable = true;
      virtualHosts."_".locations."/".extraConfig = ''
        uwsgi_pass unix:/run/privacyidea/socket;
      '';
    };
  };

  testScript = ''
    $machine->start;
    $machine->waitForUnit("multi-user.target");
    $machine->succeed("curl --fail http://localhost | grep privacyIDEA");
  '';
})
