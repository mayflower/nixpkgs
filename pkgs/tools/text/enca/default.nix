{ stdenv, fetchurl, fetchpatch, buildPackages, autoreconfHook, libiconv, recode }:

stdenv.mkDerivation rec {
  name = "enca-${version}";
  version = "1.19";

  src = fetchurl {
    url = "https://dl.cihar.com/enca/${name}.tar.xz";
    sha256 = "1f78jmrggv3jymql8imm5m9yc8nqjw5l99mpwki2245l8357wj1s";
  };

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ recode libiconv ];

  patches = [
    (fetchpatch {
      url = "https://github.com/nijel/enca/commit/2393833d133a6784e57215b89e4c4c0484555985.patch";
      sha256 = "05m70lfmkxlhpigxg0yhs1v2wlb21bw62dgxsca2pnm0s0qznplb";
    })
  ];

  meta = with stdenv.lib; {
    description = "Detects the encoding of text files and reencodes them";

    longDescription = ''
        Enca detects the encoding of text files, on the basis of knowledge
        of their language. It can also convert them to other encodings,
        allowing you to recode files without knowing their current encoding.
        It supports most of Central and East European languages, and a few
        Unicode variants, independently on language.
    '';

    license = licenses.gpl2;
  };
}
