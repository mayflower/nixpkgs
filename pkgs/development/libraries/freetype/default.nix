{ lib, stdenv, fetchurl, fetchpatch
, buildPackages, pkgsHostHost
, pkg-config, which, makeWrapper
, zlib, bzip2, libpng, gnumake, glib

, # FreeType supports LCD filtering (colloquially referred to as sub-pixel rendering).
  # LCD filtering is also known as ClearType and covered by several Microsoft patents.
  # This option allows it to be disabled. See http://www.freetype.org/patents.html.
  useEncumberedCode ? true
}:


stdenv.mkDerivation rec {
  pname = "freetype";
  version = "2.11.0";

  src = fetchurl {
    url = "mirror://savannah/${pname}/${pname}-${version}.tar.xz";
    sha256 = "sha256-i+45vTloxIBLcGFKCjrVlyma0OgkvIqtXOiq9IBnvec=";
  };

  propagatedBuildInputs = [ zlib bzip2 libpng ]; # needed when linking against freetype

  # dependence on harfbuzz is looser than the reverse dependence
  nativeBuildInputs = [ pkg-config which makeWrapper ]
    # FreeType requires GNU Make, which is not part of stdenv on FreeBSD.
    ++ lib.optional (!stdenv.isLinux) gnumake;

  patches = [
    ./enable-table-validation.patch
    (fetchpatch {
      name = "CVE-2022-27404.patch";
      url = "https://gitlab.freedesktop.org/freetype/freetype/-/commit/53dfdcd8198d2b3201a23c4bad9190519ba918db.patch";
      sha256 = "sha256-0R8bighSEipFKowD2PgGMg7WxZ4rPI+o+zyiEVOSvqA=";
    })
    (fetchpatch {
      name = "CVE-2022-27405.patch";
      url = "https://gitlab.freedesktop.org/freetype/freetype/-/commit/22a0cccb4d9d002f33c1ba7a4b36812c7d4f46b5.patch";
      sha256 = "sha256-liMquIRao2d+OOBt5Xqx1CRR0o1pKAB7RPmOXMqEs9M=";
    })
    (fetchpatch {
      name = "CVE-2022-27406.patch";
      url = "https://gitlab.freedesktop.org/freetype/freetype/-/commit/0c2bdb01a2e1d24a3e592377a6d0822856e10df2.patch";
      sha256 = "sha256-Ows8FQFAIsYH+4qfwTt6SW0wAhWtBGqfj0ry7GsHgaI=";
    })
  ] ++ lib.optional useEncumberedCode ./enable-subpixel-rendering.patch;

  outputs = [ "out" "dev" ];

  configureFlags = [ "--bindir=$(dev)/bin" "--enable-freetype-config" ];

  # native compiler to generate building tool
  CC_BUILD = "${buildPackages.stdenv.cc}/bin/cc";

  # The asm for armel is written with the 'asm' keyword.
  CFLAGS = lib.optionalString stdenv.isAarch32 "-std=gnu99";

  enableParallelBuilding = true;

  doCheck = true;

  postInstall = glib.flattenInclude + ''
    substituteInPlace $dev/bin/freetype-config \
      --replace ${buildPackages.pkg-config} ${pkgsHostHost.pkg-config}

    wrapProgram "$dev/bin/freetype-config" \
      --set PKG_CONFIG_PATH "$PKG_CONFIG_PATH:$dev/lib/pkgconfig"
  '';

  meta = with lib; {
    description = "A font rendering engine";
    longDescription = ''
      FreeType is a portable and efficient library for rendering fonts. It
      supports TrueType, Type 1, CFF fonts, and WOFF, PCF, FNT, BDF and PFR
      fonts. It has a bytecode interpreter and has an automatic hinter called
      autofit which can be used instead of hinting instructions included in
      fonts.
    '';
    homepage = "https://www.freetype.org/";
    license = licenses.gpl2Plus; # or the FreeType License (BSD + advertising clause)
    platforms = platforms.all;
    maintainers = with maintainers; [ ttuegel ];
  };
}
