{ stdenv, fetchFromGitHub, python }:

let
self = python.pkgs.buildPythonPackage rec {
  name = "weechat-matrix-2019-04-25";

  src = fetchFromGitHub {
    owner = "poljar";
    repo = "weechat-matrix";
    rev = "c1cfc4a8e4a67989d526a2c9142575e447f88cd7";
    sha256 = "0q16xr1lfc7qybm3ny7clb4gpmv4vknsppmaaafza6xvysvnm4r6";
  };

  format = "other";
  makeFlags = [ "PREFIX=${placeholder "out"}/share" ];

  passthru = {
    scripts = [ "python/matrix.py" ];
    withPyPackages = ps: with ps; [
      webcolors pyopenssl typing future atomicwrites
      attrs Logbook pygments matrix-nio matrix-client self
    ];
  };

  postInstall = ''
    mkdir -p $out/${python.sitePackages}
    ln -s $out/share/python/matrix $out/${python.sitePackages}/matrix
  '';

  #doCheck = true;
  checkInputs = with python.pkgs; [ pytest hypothesis ] ++ passthru.withPyPackages python.pkgs;
  checkPhase = ''
    python -m pytest
  '';

  meta = with stdenv.lib; {
    description = " Weechat Matrix protocol script written in python";
    homepage = https://github.com/poljar/weechat-matrix;
    maintainers = with maintainers; [ globin ma27 ];
    license = licenses.mit;
    platforms = platforms.unix;
  };
}; in self
