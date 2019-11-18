{ lib, buildPythonPackage, fetchPypi
, pyyaml
}:

buildPythonPackage rec {
  pname = "yamale";
  version = "2.0.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256:1hz4nyi0zp4jvmd94ij1z30pgcb6xdnzqqadjnjn3z6905xvnzdc";
  };

  propagatedBuildInputs = [ pyyaml ];

  # test data not included on pypi
  doCheck = false;

  meta = with lib; {
    description = "A schema and validator for YAML";
    license = licenses.mit;
    homepage = https://github.com/23andMe/Yamale;
    maintainers = with maintainers; [ globin ];
  };
}
