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
    rev = "439d8256ba97c15165e5ce2f2ab3bffe2efaa940";
    sha256 = "1barbvwkv0pwzzzqjl6bdblj44kfmkl07ffbz5bcqhsj3gpdzpjb";
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
