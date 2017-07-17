{ stdenv, pkgs, builtins, fetchurl, makeWrapper, autoreconfHook
, pkgconfig, which
, flex, bison
, linuxHeaders ? stdenv.cc.libc.linuxHeaders
, pythonPackages
, perl
, swig
, pam
, ncurses
, glibc
, utillinux
, gettext
, nettools
}:

let
  apparmor-series = "2.11";
  apparmor-version = apparmor-series;
  apparmor-archive = "2.11.0";

  apparmor-meta = component: with stdenv.lib; {
    homepage = http://apparmor.net/;
    description = "A mandatory access control system - ${component}";
    license = licenses.gpl2;
    maintainers = with maintainers; [ phreedom thoughtpolice joachifm ];
    platforms = platforms.linux;
  };

  apparmor-sources = fetchurl {
    url = "https://launchpad.net/apparmor/${apparmor-series}/${apparmor-version}/+download/apparmor-${apparmor-archive}.tar.gz";
    sha256 = "16kkvmdpl6zjb0jhxc1w7rhfdszrzg53458qdf71nxz727m8ki5i";
  };

  prePatchCommon = ''
    substituteInPlace ./common/Make.rules --replace "/usr/bin/pod2man" "${perl}/bin/pod2man"
    substituteInPlace ./common/Make.rules --replace "/usr/bin/pod2html" "${perl}/bin/pod2html"
    substituteInPlace ./common/Make.rules --replace "/usr/include/linux/capability.h" "${linuxHeaders}/include/linux/capability.h"
    substituteInPlace ./common/Make.rules --replace "/usr/share/man" "share/man"
  '';

  # FIXME: convert these to a single multiple-outputs package?

  libapparmor = stdenv.mkDerivation {
    name = "libapparmor-${apparmor-version}";
    src = apparmor-sources;

    nativeBuildInputs = [
      autoreconfHook
      bison
      flex
      pkgconfig
      swig
      which
    ];

    buildInputs = [
      perl
      pythonPackages.python
      ncurses
    ];

    # required to build apparmor-parser
    dontDisableStatic = true;

    prePatch = prePatchCommon + ''
      substituteInPlace ./libraries/libapparmor/src/Makefile.am --replace "/usr/include/netinet/in.h" "${stdenv.cc.libc.dev}/include/netinet/in.h"
      substituteInPlace ./libraries/libapparmor/src/Makefile.in --replace "/usr/include/netinet/in.h" "${stdenv.cc.libc.dev}/include/netinet/in.h"
    '';

    postPatch = "cd ./libraries/libapparmor";
    configureFlags = "--with-python --with-perl";

    outputs = [ "out" "python" ];

    postInstall = ''
      mkdir -p $python/lib
      mv $out/lib/python* $python/lib/
    '';

    meta = apparmor-meta "library";
  };

  apparmor-utils = stdenv.mkDerivation {
    name = "apparmor-utils-${apparmor-version}";
    src = apparmor-sources;

    nativeBuildInputs = [
      makeWrapper
      which
      pythonPackages.pyflakes
      gettext
    ];

    buildInputs = [
      perl
      pythonPackages.python
      libapparmor
      libapparmor.python
      apparmor-profiles
      apparmor-parser
      glibc.bin
      utillinux.bin
      nettools
    ];

    prePatch = prePatchCommon + ''
      substituteInPlace ./utils/Makefile --replace "/usr/include/linux/capability.h" "${linuxHeaders}/include/linux/capability.h"
      substituteInPlace ./utils/apparmor/ui.py --replace ", re.LOCALE" ""

      # aa-unconfined calls netstat
      substituteInPlace ./utils/aa-unconfined --replace "'/bin:/usr/bin:/sbin:/usr/sbin'" "'${nettools}/bin'"
      
      substituteInPlace ./utils/logprof.conf \
        --replace "/etc/apparmor.d" "/etc/apparmor.d ${apparmor-profiles}/etc/apparmor.d" \
        --replace "/sbin/apparmor_parser" "${apparmor-parser}/bin/apparmor_parser" \
        --replace "/usr/bin/ldd" "${stdenv.cc.libc_bin}/bin/ldd" \
        --replace "/usr/bin/logger" "" \
        --replace "/bin/logger" "${utillinux.bin}/bin/logger"
    '';
    postPatch = "cd ./utils";

    installFlags = ''DESTDIR=$(out) BINDIR=$(out)/bin VIM_INSTALL_PATH=$(out)/share PYPREFIX='';

    preCheck = ''
      for file in ./test/test-* ./test/fake_ldd ; do
        substituteInPlace $file --replace "/usr/bin/python3" "${pythonPackages.python.interpreter}"
      done

      #substituteInPlace ./test/test-aa.py \
      #  --replace "'/usr/lib/ispell/', '/usr/lib{,32,64}/**'" "'/usr/lib{,32,64}/**', '/usr/lib/ispell/'"

      substituteInPlace ./apparmor/aa.py --replace "/etc/apparmor" "$PWD"

      checkFlagsArray=(
        USE_SYSTEM=1
        LD_LIBRARY_PATH=${libapparmor}/lib
        PYTHONPATH=..:$PYTHONPATH
      )
    '';

    #doCheck = true;

    postCheck = ''
      substituteInPlace ./apparmor/aa.py --replace "$PWD" "/etc/apparmor"
    '';

    postInstall = ''
      for prog in aa-audit aa-autodep aa-cleanprof aa-complain aa-disable aa-enforce aa-genprof aa-logprof aa-mergeprof aa-status aa-unconfined ; do
        wrapProgram $out/bin/$prog --prefix PYTHONPATH : "$out/lib/${pythonPackages.python.libPrefix}/site-packages:$PYTHONPATH"
      done

      for prog in aa-notify ; do
        wrapProgram $out/bin/$prog --prefix PERL5LIB : "${libapparmor}/lib/perl5:$PERL5LIB"
      done
    '';

    meta = apparmor-meta "user-land utilities";
  };

  apparmor-parser = stdenv.mkDerivation {
    name = "apparmor-parser-${apparmor-version}";
    src = apparmor-sources;

    nativeBuildInputs = [ bison flex which ];

    buildInputs = [ libapparmor ];

    prePatch = prePatchCommon + ''
      substituteInPlace ./parser/Makefile --replace "/usr/bin/bison" "${bison}/bin/bison"
      substituteInPlace ./parser/Makefile --replace "/usr/bin/flex" "${flex}/bin/flex"
      substituteInPlace ./parser/Makefile --replace "/usr/include/linux/capability.h" "${linuxHeaders}/include/linux/capability.h"
      ## techdoc.pdf still doesn't build ...
      substituteInPlace ./parser/Makefile --replace "manpages htmlmanpages pdf" "manpages htmlmanpages"
    '';
    postPatch = "cd ./parser";
    makeFlags = ''LANGS= USE_SYSTEM=1 INCLUDEDIR=${libapparmor}/include'';
    installFlags = ''DESTDIR=$(out) DISTRO=unknown'';

    meta = apparmor-meta "rule parser";
  };

  apparmor-pam = stdenv.mkDerivation {
    name = "apparmor-pam-${apparmor-version}";
    src = apparmor-sources;

    nativeBuildInputs = [ pkgconfig which ];

    buildInputs = [ libapparmor pam ];

    postPatch = "cd ./changehat/pam_apparmor";
    makeFlags = ''USE_SYSTEM=1'';
    installFlags = ''DESTDIR=$(out)'';

    meta = apparmor-meta "PAM service";
  };

  apparmor-profiles = stdenv.mkDerivation {
    name = "apparmor-profiles-${apparmor-version}";
    src = apparmor-sources;

    nativeBuildInputs = [ which ];

    postPatch = "cd ./profiles";
    installFlags = ''DESTDIR=$(out) EXTRAS_DEST=$(out)/share/apparmor/extra-profiles'';

    meta = apparmor-meta "profiles";
  };

  apparmor-kernel-patches = stdenv.mkDerivation {
    name = "apparmor-kernel-patches-${apparmor-version}";
    src = apparmor-sources;

    phases = ''unpackPhase installPhase'';

    installPhase = ''
      mkdir "$out"
      cp -R ./kernel-patches/* "$out"
    '';

    meta = apparmor-meta "kernel patches";
  };

  apparmor-extra-profiles = import ./profiles.nix { inherit stdenv pkgs builtins; };
in

{
  inherit libapparmor apparmor-utils apparmor-parser apparmor-pam
  apparmor-profiles apparmor-kernel-patches apparmor-extra-profiles;
}
