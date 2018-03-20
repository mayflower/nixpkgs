{ lib, stdenv, fetchurl, openssl, openldap, kerberos, db, gettext, libkrb5,
  pam, fixDarwinDylibNames, autoreconfHook, fetchpatch, enableLdap ? false }:

with stdenv.lib;
stdenv.mkDerivation rec {
  name = "cyrus-sasl-${version}${optionalString (libkrb5 == null) "-without-kerberos"}";
  version = "2.1.27rc3";

  src = fetchurl {
    url = "ftp://ftp.cyrusimap.org/cyrus-sasl/${name}.tar.gz";
    sha256 = "0aivwvkacfwhblqfl8xj006633dw85pxplgdy6wa64yk5822j3x5";
  };

  outputs = [ "bin" "dev" "out" "man" "devdoc" ];

  propagatedBuildInputs = [ libkrb5 ];
  buildInputs =
    [ openssl db gettext ]
    ++ lib.optional enableLdap openldap
    ++ lib.optional stdenv.isFreeBSD autoreconfHook
    ++ lib.optional stdenv.isLinux pam
    ++ lib.optional stdenv.isDarwin fixDarwinDylibNames;

  patches = [
    ./missing-size_t.patch # https://bugzilla.redhat.com/show_bug.cgi?id=906519
  ] ++ lib.optional stdenv.isFreeBSD (
      fetchurl {
        url = "http://www.linuxfromscratch.org/patches/blfs/svn/cyrus-sasl-2.1.26-fixes-3.patch";
        sha256 = "1vh4pc2rxxm6yvykx0b7kg09jbcwcxwv5rs6yq2ag3y8p6a9x86w";
      }
    );

  configureFlags = [
    "--with-openssl=${openssl.dev}"
  ] ++ lib.optional enableLdap "--with-ldap=${openldap.dev}";

  # Set this variable at build-time to make sure $out can be evaluated.
  preConfigure = ''
    configureFlagsArray=( --with-plugindir=$out/lib/sasl2
                          --with-saslauthd=/run/saslauthd
                          --enable-login
                        )
  '';

  installFlags = lib.optional stdenv.isDarwin [ "framedir=$(out)/Library/Frameworks/SASL2.framework" ];

  postInstall = ''
    for f in $out/lib/*.la $out/lib/sasl2/*.la; do
      substituteInPlace $f --replace "${openssl.dev}/lib" "${openssl.out}/lib"
    done
  '';

  meta = {
    homepage = http://cyrusimap.web.cmu.edu/;
    description = "Library for adding authentication support to connection-based protocols";
    platforms = platforms.unix;
  };
}
