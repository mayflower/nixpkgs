{ stdenv, fetchurl, libssl, python, zlib, libuv, v8, utillinux, http-parser
, pkgconfig, runCommand, which, libtool
}:

# nodejs 0.12 can't be built on armv5tel. Armv6 with FPU, minimum I think.
# Related post: http://zo0ok.com/techfindings/archives/1820
assert stdenv.system != "armv5tel-linux";

let
  version = "4.2.2";

  deps = {
    inherit zlib libuv;

    openssl = libssl;

    # disabled system v8 because v8 3.14 no longer receives security fixes
    # we fall back to nodejs' internal v8 copy which receives backports for now
    # inherit v8
  } // (stdenv.lib.optionalAttrs (!stdenv.isDarwin) {
    inherit http-parser;
  });

  sharedConfigureFlags = name: [
    "--shared-${name}"
    "--shared-${name}-includes=${builtins.getAttr name deps}/include"
    "--shared-${name}-libpath=${builtins.getAttr name deps}/lib"
  ];

  inherit (stdenv.lib) concatMap optional optionals maintainers licenses platforms;
in stdenv.mkDerivation {
  name = "nodejs-${version}";

  src = fetchurl {
    url = "http://nodejs.org/dist/v${version}/node-v${version}.tar.gz";
    sha256 = "1c8c45b39fg2mz1c88jl0q0yhpxixdr25rpmpfskdd1m6hshkrq0";
  };

  configureFlags = concatMap sharedConfigureFlags (builtins.attrNames deps) ++ [ "--without-dtrace" ];
  dontDisableStatic = true;
  prePatch = ''
    patchShebangs .
    sed -i 's/raise.*No Xcode or CLT version detected.*/version = "7.0.0"/' tools/gyp/pylib/gyp/xcode_emulation.py
  '';

  patches = stdenv.lib.optionals stdenv.isDarwin [ ./no-xcode.patch ./pkg-libpath.patch ];

  buildInputs = [ python which zlib libuv libssl python ]
    ++ optionals stdenv.isLinux [ utillinux http-parser ]
    ++ optionals stdenv.isDarwin [ pkgconfig libssl libtool ];
  setupHook = ./setup-hook.sh;

  enableParallelBuilding = true;

  passthru.interpreterName = "nodejs";

  meta = {
    description = "Event-driven I/O framework for the V8 JavaScript engine";
    homepage = http://nodejs.org;
    license = licenses.mit;
    maintainers = [ maintainers.havvy ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
