{ lib, buildPythonPackage, fetchPypi
}:

buildPythonPackage rec {
  pname = "pycron";
  version = "1.0.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1zjqd0x21v411b7g6spvnbqd2bkc3k2848w709n84mmziz5mn3wh";
  };

  meta = with lib; {
    description = "Simple cron-like parser for Python, which determines if current datetime matches conditions";
    license = licenses.mit;
    homepage = https://github.com/kipe/pycron;
    maintainers = with maintainers; [ globin ];
  };
}
