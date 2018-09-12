{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.openldap;
  openldap = pkgs.openldap;

  dataFile = pkgs.writeText "ldap-contents.ldif" cfg.declarativeContents;
  configFile = pkgs.writeText "slapd.conf" ((optionalString cfg.defaultSchemas ''
    include ${pkgs.openldap.out}/etc/schema/core.schema
    include ${pkgs.openldap.out}/etc/schema/cosine.schema
    include ${pkgs.openldap.out}/etc/schema/inetorgperson.schema
    include ${pkgs.openldap.out}/etc/schema/nis.schema
  '') + ''
    ${cfg.extraConfig}
    database ${cfg.database}
    suffix ${cfg.suffix}
    rootdn ${cfg.rootdn}
    rootpw ${cfg.rootpw}
    directory ${cfg.dataDir}
    ${cfg.extraDatabaseConfig}
  '');
  configOpts = if cfg.configDir == null then "-f ${configFile}"
               else "-F ${cfg.configDir}";
in

{

  ###### interface

  options = {

    services.openldap = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = "
          Whether to enable the ldap server.
        ";
      };

      user = mkOption {
        type = types.str;
        default = "openldap";
        description = "User account under which slapd runs.";
      };

      group = mkOption {
        type = types.str;
        default = "openldap";
        description = "Group account under which slapd runs.";
      };

      urlList = mkOption {
        type = types.listOf types.str;
        default = [ "ldap:///" ];
        description = "URL list slapd should listen on.";
        example = [ "ldaps:///" ];
      };

      dataDir = mkOption {
        type = types.str;
        default = "/var/db/openldap";
        description = "The database directory.";
      };

      defaultSchemas = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Include the default schemas core, cosine, inetorgperson and nis.
          This setting will be ignored if configDir is set.
        '';
      };

      database = mkOption {
        type = types.str;
        default = "mdb";
        description = ''
          Database type to use for the LDAP.
          This setting will be ignored if configDir is set.
        '';
      };

      suffix = mkOption {
        type = types.str;
        example = "dc=example,dc=org";
        description = ''
          Specify the DN suffix of queries that will be passed to this backend
          database.
          This setting will be ignored if configDir is set.
        '';
      };

      rootdn = mkOption {
        type = types.str;
        example = "cn=admin,dc=example,dc=org";
        description = ''
          Specify the distinguished name that is not subject to access control
          or administrative limit restrictions for operations on this database.
          This setting will be ignored if configDir is set.
        '';
      };

      rootpw = mkOption {
        type = types.str;
        description = ''
          Password for the root user.
          This setting will be ignored if configDir is set.
        '';
      };

      configDir = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          Use this optional config directory instead of using slapd.conf
          Other settings in this NixOS module, which are specified in the
          slapd.conf will be ignored, namely: database, suffix, rootdn, rootpw,
          defaultSchemas, extraConfig, extraDatabaseConfig.
        '';
        example = "/var/db/slapd.d";
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = ''
          slapd.conf configuration before the database option.
          This setting will be ignored if configDir is set.
        '';
        example = ''
          # Subtypes of "name" (e.g. "cn" and "ou") with the
          # option ";x-hidden" can be searched for/compared,
          # but are not shown.  See slapd.access(5).
          attributeoptions x-hidden lang-
          access to attrs=name;x-hidden by * =cs

          # Protect passwords.  See slapd.access(5).
          access to attrs=userPassword  by * auth
          # Read access to other attributes and entries.
          access to * by * read
        '';
      };

      extraDatabaseConfig = mkOption {
        type = types.lines;
        default = "";
        description = ''
          slapd.conf configuration after the database option.
          This setting will be ignored if configDir is set.
        '';
        example = ''
          # Indices to maintain for this directory
          # unique id so equality match only
          index uid eq
          # allows general searching on commonname, givenname and email
          index cn,gn,mail eq,sub
          # allows multiple variants on surname searching
          index sn eq,sub
          # sub above includes subintial,subany,subfinal
          # optimise department searches
          index ou eq
          # if searches will include objectClass uncomment following
          # index objectClass eq
          # shows use of default index parameter
          index default eq,sub
          # indices missing - uses default eq,sub
          index telephonenumber

          # other database parameters
          # read more in slapd.conf reference section
          cachesize 10000
          checkpoint 128 15
        '';
      };

      declarativeContents = mkOption {
        type = with types; nullOr lines;
        default = null;
        description = ''
          Declarative contents for the LDAP database, in LDIF format.

          Note a few facts when using it. First, the database
          <emphasis>must</emphasis> be stored in the directory defined by
          <code>dataDir</code>. Second, all <code>dataDir</code> will be erased
          when starting the LDAP server. Third, modifications to the database
          are not prevented, they are just dropped on the next reboot of the
          server. Finally, performance-wise the database and indexes are rebuilt
          on each server startup, so this will slow down server startup,
          especially with large databases.
        '';
        example = ''
          dn: dc=example,dc=org
          objectClass: domain
          dc: example

          dn: ou=users,dc=example,dc=org
          objectClass = organizationalUnit
          ou: users

          # ...
        '';
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    environment.systemPackages = [ openldap ];

    systemd.services.openldap = {
      description = "LDAP server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      preStart = ''
        mkdir -p /var/run/slapd
        chown -R "${cfg.user}:${cfg.group}" /var/run/slapd
        ${optionalString (cfg.declarativeContents != null) ''
          rm -Rf "${cfg.dataDir}"
        ''}
        mkdir -p "${cfg.dataDir}"
        ${optionalString (cfg.declarativeContents != null) ''
          ${openldap.out}/bin/slapadd ${configOpts} -l ${dataFile}
        ''}
        chown -R "${cfg.user}:${cfg.group}" "${cfg.dataDir}"
      '';
      serviceConfig.ExecStart =
        "${openldap.out}/libexec/slapd -d 0 " +
          "-u '${cfg.user}' -g '${cfg.group}' " +
          "-h '${concatStringsSep " " cfg.urlList}' " +
          "${configOpts}";
    };

    users.users.openldap =
      { name = cfg.user;
        group = cfg.group;
        uid = config.ids.uids.openldap;
      };

    users.groups.openldap =
      { name = cfg.group;
        gid = config.ids.gids.openldap;
      };

  };
}
