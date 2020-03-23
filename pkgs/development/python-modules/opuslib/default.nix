{ lib
, buildPythonPackage
, fetchPypi
, coverage
, nose
, libopus
}:

buildPythonPackage rec {
  pname = "opuslib";
  version = "3.0.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "2cb045e5b03e7fc50dfefe431e3404dddddbd8f5961c10c51e32dfb69a044c97";
  };

  doCheck = false;

  # # Package conditions to handle
  # # might have to sed setup.py and egg.info in patchPhase
  # # sed -i "s/<package>.../<package>/"
  # coverage >= 4.4.1
  # nose >= 1.3.7
  checkInputs = [
    coverage
    nose
  ];

  checkPhase = ''
    nosetests
  '';

  postPatch = ''
    substituteInPlace opuslib/api/__init__.py \
      --replace "lib_location = find_library('opus')" "lib_location = '${libopus}/lib/libopus.so'"
  '';

  meta = with lib; {
    description = "Python bindings to the libopus, IETF low-delay audio codec";
    homepage = https://github.com/onbeep/opuslib;
    license = licenses.bsd3;
    maintainers = with maintainers; [ elseym ];
  };
}