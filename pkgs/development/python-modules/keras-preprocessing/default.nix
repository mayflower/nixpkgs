{ lib, buildPythonPackage, fetchPypi, numpy, six, scipy, pillow, pytest, Keras }:

buildPythonPackage rec {
  pname = "Keras_Preprocessing";
  version = "1.0.9";

  src = fetchPypi {
    inherit pname version;
    sha256 = "5e3700117981c2db762e512ed6586638124fac5842170701628088a11aeb51ac";
  };

  propagatedBuildInputs = [
    # required
    numpy six
    # optional
    scipy pillow
  ];

  checkInputs = [
    pytest Keras
  ];

  checkPhase = ''
    py.test tests/
  '';

  # Cyclic dependency: keras-preprocessing's tests require Keras, which requires keras-preprocessing
  doCheck = false;

  meta = with lib; {
    description = "Easy data preprocessing and data augmentation for deep learning models";
    homepage = https://github.com/keras-team/keras-preprocessing;
    license = licenses.mit;
  };
}
