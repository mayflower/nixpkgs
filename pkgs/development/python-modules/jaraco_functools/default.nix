{ lib, buildPythonPackage, fetchPypi, python
, setuptools_scm
, more-itertools, backports_functools_lru_cache }:

buildPythonPackage rec {
  pname = "jaraco.functools";
  version = "2.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "35ba944f52b1a7beee8843a5aa6752d1d5b79893eeb7770ea98be6b637bf9345";
  };

  propagatedBuildInputs = [ more-itertools backports_functools_lru_cache ];

  doCheck = false;

  buildInputs = [ setuptools_scm ];

  postInstall = ''
    rm -f $out/${python.sitePackages}/jaraco/__pycache__/__init__.*.pyc
  '';

  meta = with lib; {
    description = "Additional functools in the spirit of stdlib's functools";
    homepage = https://github.com/jaraco/jaraco.functools;
    license = licenses.mit;
  };
}
