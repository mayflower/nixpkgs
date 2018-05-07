{ stdenv, buildPythonPackage, fetchFromGitLab, future
, mailmanclient, pytz, django-gravatar2, django, django-allauth
, django_compressor, mock
}:

buildPythonPackage rec {
  pname = "django-mailman3";
  name = "${pname}-${version}";
  version = "1.2.0a2";

  src = fetchFromGitLab {
    owner = "globin";
    repo = "django-mailman3";
    rev = "68151db68953f8564230e4ab09612fc2b6e1b87f";
    sha256 = "15id91b14ck0my3i2l3vj99n2crilf6yjlqsb8cwqxjkgblz9kwd";
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
