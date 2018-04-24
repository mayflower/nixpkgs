{ system ? builtins.currentSystem }:
with import ../lib/testing.nix { inherit system; };
with pkgs.lib;
let
  postgresql-versions = pkgs.callPackages ../../pkgs/servers/sql/postgresql { };
  test-sql = pkgs.writeText "postgresql-test" ''
    CREATE EXTENSION pgcrypto; -- just to check if lib loading works
    CREATE TABLE sth (
      id int
    );
    INSERT INTO sth (id) VALUES (1);
    INSERT INTO sth (id) VALUES (1);
    INSERT INTO sth (id) VALUES (1);
    INSERT INTO sth (id) VALUES (1);
    INSERT INTO sth (id) VALUES (1);
    CREATE TABLE xmltest ( doc xml );
    INSERT INTO xmltest (doc) VALUES ('<test>ok</test>'); -- check if libxml2 enabled
  '';
  test2-sql = pkgs.writeText "postgresql-test" ''
    INSERT INTO sth (id) VALUES (1);
    INSERT INTO xmltest (doc) VALUES ('<test>ok</test>');
  '';
  make-postgresql-test = postgresql-name: postgresql-package: makeTest {
    name = postgresql-name;
    meta = with pkgs.stdenv.lib.maintainers; {
      maintainers = [ zagy ];
    };

    nodes.db1 = { ... }:
      {
        services.postgresql.package = postgresql-package;
        services.postgresql.enable = true;
        networking.firewall.allowedTCPPorts = [ 5432 ];
        services.postgresql.enableTCPIP = true;
        services.postgresql.authentication = ''
          host    replication     replica        0.0.0.0/0    md5
        '';
        services.postgresql.initialScript = pkgs.writeText "pg-init.sql" ''
          CREATE ROLE replica REPLICATION LOGIN PASSWORD 'foobar';
          SELECT * FROM pg_create_physical_replication_slot('db2_slot');
        '';
      };

    nodes.db2 = { ... }:
      {
        services.postgresql.package = postgresql-package;
        services.postgresql.enable = true;
        services.postgresql.recoveryConfig = ''
          standby_mode = 'on'
          primary_conninfo = 'host=db1 port=5432 user=replica password=foobar'
          primary_slot_name = 'db2_slot'
        '';
      };

    testScript = ''
      sub check_count {
        my ($select, $nlines) = @_;
        return 'test $(sudo -u postgres psql postgres -tAc "' . $select . '"|wc -l) -eq ' . $nlines;
      }

      $db1->start;

      $db1->waitForUnit("postgresql");

      # postgresql should be available just after unit start
      $db1->succeed("cat ${test-sql} | sudo -u postgres psql");
      #$db1->shutdown; # make sure that postgresql survive restart (bug #1735)
      #sleep(2);
      #$db1->start;
      #$db1->waitForUnit("postgresql");

      $db1->fail(check_count("SELECT * FROM sth;", 3));
      $db1->succeed(check_count("SELECT * FROM sth;", 5));
      $db1->fail(check_count("SELECT * FROM sth;", 4));
      $db1->succeed(check_count("SELECT xpath(\'/test/text()\', doc) FROM xmltest;", 1));

      $db2->start;
      $db2->waitForUnit("postgresql");
      $db2->systemctl("stop postgresql");
      $db2->succeed("rm /var/lib/postgresql/10.0 -r; pg_basebackup -D /var/lib/postgresql/10.0 -S db2_slot -h db1 -d 'user=replica password=foobar'; chown -R postgres:postgres /var/lib/postgresql/10.0");
      $db2->systemctl("start postgresql");
      $db2->waitForUnit("postgresql");

      $db2->succeed(check_count("SELECT * FROM sth;", 5));
      $db2->succeed(check_count("SELECT xpath(\'/test/text()\', doc) FROM xmltest;", 1));

      $db2->shutdown;
      $db1->succeed("cat ${test2-sql} | sudo -u postgres psql");
      $db2->start;
      $db2->waitForUnit("postgresql");

      $db2->fail(check_count("SELECT * FROM sth;", 5));
      $db2->succeed(check_count("SELECT * FROM sth;", 6));
      $db2->fail(check_count("SELECT xpath(\'/test/text()\', doc) FROM xmltest;", 1));
      $db2->succeed(check_count("SELECT xpath(\'/test/text()\', doc) FROM xmltest;", 2));
    '';

  };
in
  mapAttrs' (p-name: p-package: {name=p-name; value=make-postgresql-test p-name p-package;}) postgresql-versions
