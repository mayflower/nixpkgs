{ stdenv, buildPythonPackage, fetchFromGitLab, future
, mailmanclient, pytz, django-gravatar2, django, django-allauth
, django_compressor, mock
}:

buildPythonPackage rec {
  pname = "django-mailman3";
  name = "${pname}-${version}";
  version = "1.1.0+python3-patch";

  src = fetchFromGitLab {
    owner = "mailman";
    repo = "django-mailman3";
    rev = "a4e1c5d366d44ea3de13d80b14716b91d624fd5f";
    sha256 = "0l6x0j6cs3zkibfc3k5mll2zaqjg49sps5qhhq38067p0rw9anyp";
  };

  propagatedBuildInputs = [
    mailmanclient pytz django-gravatar2 django django-allauth future django_compressor
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
