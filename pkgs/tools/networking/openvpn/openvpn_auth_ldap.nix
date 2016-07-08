{ stdenv, pkgs, fetchgit, autoconf, gcobjc5, openldap, openssl, openvpn, re2c }:

stdenv.mkDerivation rec {
  name = "openvpn-auth-ldap-193071e";
  src = fetchgit {
    url = https://github.com/threerings/openvpn-auth-ldap.git;
    rev = "193071e9d7d8ef2fb446f059bf03de841747d32f";
    sha256  = "0x3d0rbxln3pszs0bhk8sp3f5y9r6q5dhfzwi5c19pjcmgfnilfc";
  };

  gcobjc5 = pkgs.lib.overrideDerivation pkgs.gcobjc5 ( drv: {
    hardeningDisable  = [ "all" ];
  });

  buildInputs = [ autoconf gcobjc5 openldap openssl openvpn re2c ];

  preConfigure  = ''
    autoconf
  '';

  configureFlags = [
    "--with-openvpn=${openvpn}"
  ];

  meta = {
    description = "Openvpn ldap plugin";
    homepage = https://github.com/threerings/openvpn-auth-ldap;
    maintainers = [ ];
    platforms = stdenv.lib.platforms.unix;
  };
}
