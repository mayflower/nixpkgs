{ stdenv, python3Packages, openssl }:

python3Packages.buildPythonPackage rec {
  pname = "privacyIDEA";
  version = "3.2.2";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "1bg6dfsjfd9xjxxvada7a711sfbhk7ydb3fr7zxc9dykihfh9gic";
  };

  postPatch = ''
    substituteInPlace privacyidea/lib/utils/__init__.py \
      --replace 'import pkg_resources' '# no pkg_resources' \
      --replace 'pkg_resources.get_distribution("privacyidea").version' \
                '"${version}"'
  '';

  patches = [ ./add-description.patch ./0001-remove-subscription-check.patch ];

  postInstall = ''
    substituteInPlace $out/etc/privacyidea/privacyideaapp.wsgi \
      --replace '"/etc/privacyidea/pi.cfg"' 'sys.argv[1]'
  '';

  checkInputs = with python3Packages; [ mock pytest openssl ];

  propagatedBuildInputs = with python3Packages; [
    pillow oauth2client configobj beautifulsoup4 pyjwt requests
    werkzeug lxml pyyaml python-gnupg flask-babel flask_migrate
    passlib sqlsoup croniter netaddr flask_script ldap3 qrcode
    pymysql pyrad defusedxml flask-versioned redis responses
    psycopg2 setuptools
  ];

  doCheck = false;
}
