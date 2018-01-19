{ stdenv, fetchgit, pythonPackages }:

pythonPackages.buildPythonApplication rec {
  name = "privacyidea-${version}";
  version = "2.21.1";

  src = fetchgit {
    url = "https://github.com/privacyidea/privacyidea.git";
    rev = "refs/tags/v${version}";
    fetchSubmodules = true;
    sha256 = "09y6rhpwfbi35zlvsm6y2vmav4a8zdlvw7cybm07wbqv1zc711lz";
  };

  postPatch = ''
    substituteInPlace privacyidea/api/lib/utils.py \
      --replace 'import pkg_resources' '# no pkg_resources' \
      --replace 'pkg_resources.get_distribution("privacyidea").version' \
                '"${version}"'
    sed -i '/argparse/d' setup.py
  '';

  postInstall = ''
    substituteInPlace $out/etc/privacyidea/privacyideaapp.wsgi \
      --replace '"/etc/privacyidea/pi.cfg"' 'sys.argv[1]'
  '';

  buildInputs = with pythonPackages; [ docutils ];
  propagatedBuildInputs = with pythonPackages; [
    pyusb pyasn1 pyyaml flask_sqlalchemy pillow flask_script python-gnupg
    funcparserlib pyopenssl passlib beautifulsoup4 flask_migrate lxml
    requests netaddr configobj ldap3 pygments pymysql sqlsoup pyjwt
    bcrypt pyrad qrcode defusedxml flaskbabel pycrypto-original matplotlib psycopg2
    pandas
  ];
}
