{ lib, buildPythonPackage, fetchPypi
, hiredis, async-timeout
}:

buildPythonPackage rec {
  pname = "aioredis";
  version = "1.3.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "11kfsnf0ank0gvdigqknvhmwg3h7gwb17x26hdd64lh6zd42gnl6";
  };

  propagatedBuildInputs = [
    hiredis async-timeout
  ];

  meta = with lib; {
    description = "asyncio (PEP 3156) Redis client library";
    license = licenses.mit;
    homepage = https://github.com/aio-libs/aioredis;
    maintainers = with maintainers; [ globin ];
  };
}
