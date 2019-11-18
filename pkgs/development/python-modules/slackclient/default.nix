{ stdenv, buildPythonPackage, fetchPypi
, aiohttp, black, pytestrunner
}:

buildPythonPackage rec {
  pname = "slackclient";
  version = "2.3.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1y6hm6hhj1xrawmngkn16sddz2khpf9qcskkgs7rgvkdhv9b2g6n";
  };

  propagatedBuildInputs = [ aiohttp black pytestrunner ];

  # tests not included on pypi
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Slack Python SDK";
    homepage = https://github.com/slackapi/python-slackclient;
    license = licenses.mit;
    maintainers = with maintainers; [ psyanticy ];
  };
}

