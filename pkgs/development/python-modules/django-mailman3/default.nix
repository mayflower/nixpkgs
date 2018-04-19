{ stdenv, buildPythonPackage, fetchFromGitLab, future
, mailmanclient, pytz, django-gravatar2, django, django-allauth
, django_compressor, mock
}:

buildPythonPackage rec {
  pname = "django-mailman3";
  name = "${pname}-${version}";
  version = "1.2.0a1";

  src = fetchFromGitLab {
    owner = "mailman";
    repo = "django-mailman3";
    rev = version;
    sha256 = "0h2vclvnpjszmzakd72l6b6qdq0zbi9jqlgq97csynncw9xr1qig";
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
