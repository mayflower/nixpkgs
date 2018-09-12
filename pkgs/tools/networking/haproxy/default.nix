{ useLua ? !stdenv.isDarwin
, usePcre ? true
, stdenv, fetchurl, fetchpatch
, openssl, zlib, lua5_3 ? null, pcre ? null
}:

assert useLua -> lua5_3 != null;
assert usePcre -> pcre != null;

stdenv.mkDerivation rec {
  pname = "haproxy";
  version = "1.8.13";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://www.haproxy.org/download/${stdenv.lib.versions.majorMinor version}/src/${name}.tar.gz";
    sha256 = "2bf5dafbb5f1530c0e67ab63666565de948591f8e0ee2a1d3c84c45e738220f1";
  };

  patches = stdenv.lib.optional stdenv.isDarwin (fetchpatch {
    name = "fix-darwin-no-threads-build.patch";
    url = "https://git.haproxy.org/?p=haproxy-1.8.git;a=patch;h=fbf09c441a4e72c4a690bc7ef25d3374767fe5c5;hp=3157ef219c493f3b01192f1b809a086a5b119a1e";
    sha256 = "16ckzb160anf7xih7mmqy59pfz8sdywmyblxnr7lz9xix3jwk55r";
  });

  buildInputs = [ openssl zlib ]
    ++ stdenv.lib.optional useLua lua5_3
    ++ stdenv.lib.optional usePcre pcre;

  # TODO: make it work on bsd as well
  makeFlags = [
    "PREFIX=\${out}"
    ("TARGET=" + (if stdenv.isSunOS  then "solaris"
             else if stdenv.isLinux  then "linux2628"
             else if stdenv.isDarwin then "osx"
             else "generic"))
  ];
  buildFlags = [
    "USE_OPENSSL=yes"
    "USE_ZLIB=yes"
  ] ++ stdenv.lib.optionals usePcre [
    "USE_PCRE=yes"
    "USE_PCRE_JIT=yes"
  ] ++ stdenv.lib.optionals useLua [
    "USE_LUA=yes"
    "LUA_LIB=${lua5_3}/lib"
    "LUA_INC=${lua5_3}/include"
  ] ++ stdenv.lib.optional stdenv.isDarwin "CC=cc"
    ++ stdenv.lib.optional stdenv.isLinux "USE_GETADDRINFO=1";

  meta = {
    description = "Reliable, high performance TCP/HTTP load balancer";
    longDescription = ''
      HAProxy is a free, very fast and reliable solution offering high
      availability, load balancing, and proxying for TCP and HTTP-based
      applications. It is particularly suited for web sites crawling under very
      high loads while needing persistence or Layer7 processing. Supporting
      tens of thousands of connections is clearly realistic with todays
      hardware.
    '';
    homepage = http://haproxy.1wt.eu;
    maintainers = with stdenv.lib.maintainers; [ fuzzy-id garbas ];
    platforms = with stdenv.lib.platforms; linux ++ darwin;
    license = stdenv.lib.licenses.gpl2;
  };
}
