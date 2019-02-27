{ lib, buildPythonPackage, fetchPypi, dateutil }:

buildPythonPackage rec {
  pname = "croniter";
  version = "0.3.27";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0mrpabkyiy7w38528ncm8x9vkbzdbxf1f59xjmzc4f7zl24j3mzv";
  };

  propagatedBuildInputs = [ dateutil ];

  meta = with lib; {
    description = "croniter provides iteration for datetime object with cron like format";
    homepage = http://github.com/kiorky/croniter;
    license = licenses.mit;
  };
}
