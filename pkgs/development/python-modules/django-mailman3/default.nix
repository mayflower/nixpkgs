{ stdenv, buildPythonPackage, fetchFromGitLab, future
, mailmanclient, pytz, django-gravatar2, django, django-allauth
, django_compressor, mock
}:

buildPythonPackage rec {
  pname = "django-mailman3";
  name = "${pname}-${version}";
  version = "1.2.0a2";

  src = fetchFromGitLab {
    owner = "mailman";
    repo = "django-mailman3";
    rev = version;
    sha256 = "1x26dfdby6gsb5s57kyw55n8fwivv2r2vphvica76afzzf1cq4zc";
  };

  propagatedBuildInputs = [
    mailmanclient pytz django-gravatar2 django django-allauth future
    django_compressor
  ];
  checkInputs = [ mock ];

  checkPhase = ''
    cd $NIX_BUILD_TOP/$sourceRoot
    PYTHONPATH=.:$PYTHONPATH django-admin.py test --settings=django_mailman3.tests.settings_test
  '';

  meta = with stdenv.lib; {
    description = "Django library for Mailman UIs";
    homepage = https://gitlab.com/mailman/django-mailman3;
    license = licenses.gpl3;
    maintainers = with maintainers; [ globin ];
  };
}
