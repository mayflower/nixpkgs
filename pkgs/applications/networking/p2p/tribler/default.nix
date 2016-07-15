{ stdenv, fetchurl, pythonPackages, makeWrapper, nettools, libtorrentRasterbar, imagemagick
, enablePlayer ? false, vlc ? null }:


stdenv.mkDerivation rec {
  name = "tribler-${version}";
  version = "v6.5.2";

  src = fetchurl {
    url = "https://github.com/Tribler/tribler/releases/download/${version}/Tribler-${version}.tar.xz";
    sha256 = "03zyi9hyh57kjikpb25wbshlqhna8idjj4nwihiqwxwrd49mkp63";
  };

  buildInputs = [
    pythonPackages.python
    pythonPackages.wrapPython
    makeWrapper
    imagemagick
  ];

  pythonPath = [
    libtorrentRasterbar
    pythonPackages.wxPython
    pythonPackages.curses
    pythonPackages.apsw
    pythonPackages.twisted
    pythonPackages.gmpy
    pythonPackages.netifaces
    pythonPackages.pillow
    pythonPackages.pycrypto
    pythonPackages.pyasn1
    pythonPackages.requests
    pythonPackages.setuptools
    pythonPackages.m2crypto
    pythonPackages.sqlite3
  ];

  installPhase =
    ''
      find . -name '*.png' -exec convert -strip {} {} \;
      # Nasty hack; call wrapPythonPrograms to set program_PYTHONPATH.
      wrapPythonPrograms

      mkdir -p $out/share/tribler
      cp -prvd Tribler $out/share/tribler/

      makeWrapper ${pythonPackages.python}/bin/python $out/bin/tribler \
          --set _TRIBLERPATH $out/share/tribler \
          --set PYTHONPATH $out/share/tribler:$program_PYTHONPATH \
          --run 'cd $_TRIBLERPATH' \
          --add-flags "-O $out/share/tribler/Tribler/Main/tribler.py" \
          ${stdenv.lib.optionalString enablePlayer ''
            --prefix LD_LIBRARY_PATH : ${vlc}/lib
          ''}
    '';

  meta = {
    homepage = http://www.tribler.org/;
    description = "A completely decentralised P2P filesharing client based on the Bittorrent protocol";
    license = stdenv.lib.licenses.lgpl21;
    broken = true; # wxPython 2.8 was removed
  };
}
