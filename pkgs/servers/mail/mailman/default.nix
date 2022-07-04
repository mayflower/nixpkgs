{ newScope, lib, python3 }:

let
  self = lib.makeExtensible (self: let inherit (self) callPackage; in {
    callPackage = newScope self;

    python3 = callPackage ./python.nix { inherit python3; };

    hyperkitty = callPackage ./hyperkitty.nix { };

    mailman = callPackage ./package.nix { };

    mailman-hyperkitty = callPackage ./mailman-hyperkitty.nix { };

    postorius = callPackage ./postorius.nix { };

    web = callPackage ./web.nix { };

    buildEnv = { web ? self.web
               , mailman ? self.mailman
               , mailman-hyperkitty ? self.mailman-hyperkitty
               , withHyperkitty ? false
               , withLDAP ? false
               }:
      self.python3.withPackages
        (ps:
        [ web mailman ps.psycopg2 ]
          ++ lib.optionals withLDAP [ ps.ldap ps.django-auth-ldap ]
          ++ lib.optional withHyperkitty mailman-hyperkitty);
      });

in self
