{ stdenv
, buildPythonPackage
, fetchpatch
, fetchPypi
, pbr
, pythonix
, pythonAtLeast
}:

buildPythonPackage rec {
  pname = "nixpkgs";
  version = "0.2.4";
  disabled = ! pythonAtLeast "3.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0dlvq4bpamhlva86042wlc0xxfsxlpdgm2adfb1c6y3vjgbm0nvd";
  };

  patches = [
    # Patch should be dropped once https://github.com/t184256/nixpkgs-python-importer/pull/7
    # is merged and in a release
    (fetchpatch {
      url = "https://github.com/adisbladis/nixpkgs-python-importer/commit/749e05f1.patch";
      sha256 = "1a72phazpqf6vf3hl3m84z9i5n6h1xpa53bqxnpsff6agxxhd21b";
    })
  ];

  buildInputs = [ pbr ];
  propagatedBuildInputs = [ pythonix ];

  meta = with stdenv.lib; {
    description = "Allows to `from nixpkgs import` stuff in interactive Python sessions";
    homepage = https://github.com/t184256/nixpkgs-python-importer;
    license = licenses.mit;
    maintainers = with maintainers; [ t184256 ];
  };

}
