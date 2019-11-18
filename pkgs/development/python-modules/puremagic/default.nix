{ lib, buildPythonPackage, fetchPypi
}:

buildPythonPackage rec {
  pname = "puremagic";
  version = "1.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1ghn9rcggdikq12112rl0d0w5xvnil8ypwyj2dijh9n76jda59mr";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace '"argparse"' ""
  '';

  # test data not included on pypi
  doCheck = false;

  meta = with lib; {
    description = "Pure python implementation of magic file detection";
    license = licenses.mit;
    homepage = https://github.com/cdgriffith/puremagic;
    maintainers = with maintainers; [ globin ];
  };
}
