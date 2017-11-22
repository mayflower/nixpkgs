{ stdenv, buildPythonPackage, fetchFromGitHub, requests, requests_oauthlib
, django, python-openid, mock, coverage }:

buildPythonPackage rec {
  pname = "django-allauth";
  name = "${pname}-${version}";
  version = "0.34.0";

  # no tests on PyPI
  src = fetchFromGitHub {
    owner = "pennersr";
    repo = pname;
    rev = version;
    sha256 = "1xbvgng2hgkygmvlymlc8k80lj4mn6d93in1jcc4619agk6jr90d";
  };

  propagatedBuildInputs = [ requests requests_oauthlib django python-openid ];

  checkInputs = [ coverage mock ];

  doCheck = false;
  checkPhase = ''
    cd $NIX_BUILD_TOP/$sourceRoot
    coverage run manage.py test allauth
  '';

  meta = with stdenv.lib; {
    description = "Integrated set of Django applications addressing authentication, registration, account management as well as 3rd party (social) account authentication";
    homepage = https://www.intenct.nl/projects/django-allauth;
    license = licenses.mit;
  };
}
