{ lib
, buildPythonPackage
, fetchPypi
, pytest
, nose
, glibcLocales
, entrypoints
, bleach
, mistune
, jinja2
, pygments
, traitlets
, testpath
, jupyter_core
, nbformat
, ipykernel
, pandocfilters
, tornado
, jupyter_client
, defusedxml
}:

buildPythonPackage rec {
  pname = "nbconvert";
  version = "5.6.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "15bni48nsaqwd2byi2gqq6s8q0dzbj6mfpxr56jnhzbfqa74cyj2";
  };

  checkInputs = [ nose pytest glibcLocales ];

  propagatedBuildInputs = [
    entrypoints bleach mistune jinja2 pygments traitlets testpath
    jupyter_core nbformat ipykernel pandocfilters tornado jupyter_client
    defusedxml
  ];

  # disable preprocessor tests for ipython 7
  # see issue https://github.com/jupyter/nbconvert/issues/898
  checkPhase = ''
    export LC_ALL=en_US.UTF-8
    HOME=$(mktemp -d) py.test -v --ignore="nbconvert/preprocessors/tests/test_execute.py"
  '';

  meta = {
    description = "Converting Jupyter Notebooks";
    homepage = https://jupyter.org/;
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fridh ];
  };
}
