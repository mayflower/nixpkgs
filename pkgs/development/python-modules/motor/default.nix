{ lib, buildPythonPackage, fetchPypi
, pymongo
}:

buildPythonPackage rec {
  pname = "motor";
  version = "2.0.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0kpq70k2xcjgw4hvsic54rvawk390ms4y4zv7szm1g12njdc0dfh";
  };

  propagatedBuildInputs = [ pymongo ];

  doCheck = false;

  meta = with lib; {
    description = "Non-blocking MongoDB driver for Tornado or asyncio";
    license = licenses.asl20;
    homepage = https://github.com/mongodb/motor;
    maintainers = with maintainers; [ globin ];
  };
}
