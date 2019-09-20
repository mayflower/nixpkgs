{ stdenv, buildGoPackage, fetchFromGitHub, libobjc, IOKit, fetchpatch }:

buildGoPackage rec {
  pname = "go-ethereum";
  version = "1.9.3";

  goPackagePath = "github.com/ethereum/go-ethereum";

  # Fix for usb-related segmentation faults on darwin
  propagatedBuildInputs =
    stdenv.lib.optionals stdenv.isDarwin [ libobjc IOKit ];

  # Fixes Cgo related build failures (see https://github.com/NixOS/nixpkgs/issues/25959 )
  hardeningDisable = [ "fortify" ];

  # Apply ethereum/go-ethereum#19183 to fix the aarch64 build failure.
  #
  # TODO Remove this patch when upstream (https://github.com/ethereum/go-ethereum)
  # fix this problem in the future release.
  patches = [
    (fetchpatch {
      url = "https://github.com/ethereum/go-ethereum/commit/39bd2609.patch";
      sha256 = "1a362hzvcjk505hicv25kziy3c6s5an4j7rk4jibcxwgvygb3mz5";
    })
 ];

  src = fetchFromGitHub {
    owner = "ethereum";
    repo = pname;
    rev = "v${version}";
    sha256 = "0lv6gxp34j26hqazcvyr4c7rsl1vljm6cfzkcmlapsjdgym505bg";
  };

  meta = with stdenv.lib; {
    homepage = "https://geth.ethereum.org/";
    description = "Official golang implementation of the Ethereum protocol";
    license = with licenses; [ lgpl3 gpl3 ];
    maintainers = with maintainers; [ adisbladis asymmetric lionello xrelkd ];
  };
}
