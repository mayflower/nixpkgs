{ stdenv, fetchFromGitHub, fetchsvn, fetchpatch, cmake, pkgconfig
, openal, freealut, libGLU_combined, libvorbis, libogg, gettext, curl, freetype
, fribidi, libtool, bluez, libjpeg, libpng, zlib, libX11, libXrandr, enet }:

let
  dir = "stk-code";

in stdenv.mkDerivation rec {
  pname = "supertuxkart";
  version = "1.0";

  srcs = [
    (fetchFromGitHub {
      owner  = "supertuxkart";
      repo   = "stk-code";
      rev    = version;
      sha256 = "03mrnzrvfdgjc687n718f5zsray6vbdlv4irzy2mfi78bz3bkjll";
      name   = dir;
    })
    (fetchsvn {
      url    = "https://svn.code.sf.net/p/supertuxkart/code/stk-assets";
      rev    = "18212";
      sha256 = "1dyj8r5rfifhnhayga8w8irkpa99vw57xjmy74cp8xz8g7zvdzqf";
      name   = "stk-assets";
    })
  ];

  nativeBuildInputs = [ cmake gettext libtool pkgconfig ];

  buildInputs = [
    libX11 libXrandr
    openal freealut libGLU_combined libvorbis libogg zlib freetype
    curl fribidi bluez libjpeg libpng enet
  ];

  # https://github.com/supertuxkart/stk-code/issues/3557#issuecomment-440794379
  patches = [
    (fetchpatch {
      url = "https://github.com/supertuxkart/stk-code/commit/3a3953f38c3555e87f3608d0291dbfccf34e9775.patch";
      sha256 = "13mr5pwf45g7frpxzlxiyiq39qi3z9spd7l6gi8i3dr3li9wrb1k";
    })
  ];

  enableParallelBuilding = true;

  cmakeFlags = [
    "-DBUILD_RECORDER=OFF"         # libopenglrecorder is not in nixpkgs
    "-DUSE_SYSTEM_ANGELSCRIPT=OFF" # doesn't work with 2.31.2 or 2.32.0
  ];

  sourceRoot = dir;

  meta = with stdenv.lib; {
    description = "A Free 3D kart racing game";
    longDescription = ''
      SuperTuxKart is a Free 3D kart racing game, with many tracks,
      characters and items for you to try, similar in spirit to Mario
      Kart.
    '';
    homepage = https://supertuxkart.net/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ pyrolagus fuuzetsu peterhoeg ];
    platforms = with platforms; linux;
  };
}
