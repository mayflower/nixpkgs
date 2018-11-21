{ fetchFromGitHub }:

rec {
  version = "unstable-20181002";
  src = fetchFromGitHub {
    owner = "NICMx";
    repo = "Jool";
    rev = "89b3c1098d2e05a67931805c6eed3182b03b8a83";
    sha256 = "1l56b6966i25xx6ap6ahd3fgnal4bgb2k5fyfnqndhsm7zvb89z2";
  };
}
