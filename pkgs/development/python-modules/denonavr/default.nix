{ lib, buildPythonPackage, fetchPypi, requests, tox }:

buildPythonPackage rec {
  pname = "denonavr";
  version = "0.7.8";

  src = fetchPypi {
    inherit pname version;
    sha256 = "03w1avrwz9ckrmx96zpbdx6ill11k6am5cax9al6s5sf25bpfvac";
  };

  propagatedBuildInputs = [ requests ];

  checkInputs = [ tox ];

  meta = with lib; {
    description = "Automation Library for Denon AVR receivers";
    license = licenses.mit;
    maintainers = with maintainers; [ globin ];
    homepage = "https://github.com/scarface-4711/denonavr";
  };
}
