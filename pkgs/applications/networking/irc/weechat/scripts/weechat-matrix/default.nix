{ stdenv, fetchFromGitHub, python3 }:

let
  deps = ps: with ps; [
    webcolors pyopenssl future atomicwrites
    attrs Logbook pygments matrix-nio matrix-client
  ];
self = python3.pkgs.buildPythonPackage rec {
  name = "weechat-matrix-2019-10-20";

  src = fetchFromGitHub {
    owner = "poljar";
    repo = "weechat-matrix";
    rev = "4a3f5217bcf5aebb9a7636cbfd5dfca50a30152d";
    sha256 = "139rw1hs0fm1azdjjhds19sdn9wgdkx3l7anzz6him60vi46fqil";
  };

  format = "other";
  makeFlags = [ "PREFIX=${placeholder "out"}/share" ];

  passthru = {
    scripts = [ "python/matrix.py" ];
    withPyPackages = ps: (deps ps) ++ [ self ];
  };

  postInstall = ''
    mkdir -p $out/${python3.sitePackages}
    ln -s $out/share/python/matrix $out/${python3.sitePackages}/matrix
  '';

  checkInputs = with python3.pkgs; [ pytest hypothesis ] ++ deps python3.pkgs;
  checkPhase = ''
    python -m pytest
  '';

  meta = with stdenv.lib; {
    description = " Weechat Matrix protocol script written in python";
    homepage = https://github.com/poljar/weechat-matrix;
    maintainers = with maintainers; [ globin ma27 ];
    license = licenses.mit;
    platforms = platforms.unix;

    # As of 2019-06-30, all of the dependencies are available on macOS but the
    # package itself does not build.
    broken = stdenv.isDarwin;
  };
}; in self
