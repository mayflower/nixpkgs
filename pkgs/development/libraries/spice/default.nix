{ lib, stdenv
, fetchgit
, meson
, ninja
, pkg-config
, pixman
, alsa-lib
, openssl
, libXrandr
, libXfixes
, libXext
, libXrender
, libXinerama
, libjpeg
, zlib
, spice-protocol
, python3
, glib
, cyrus_sasl
, libcacard
, lz4
, libopus
, gst_all_1
, orc
}:

stdenv.mkDerivation rec {
  pname = "spice";
  version = "0.15.0";

  src = fetchgit {
    url = "https://gitlab.freedesktop.org/spice/spice.git";
    rev = "v${version}";
    sha256 = "1ablv8xizd2yn15i5d246yhgqprx3cya8f8qzy0h0a3jz9388kbm";
  };

  postPatch = ''
    patchShebangs build-aux
    substituteInPlace meson.build \
      --replace 'meson.project_version()' "'${version}'"
  '';


  nativeBuildInputs = [
    glib
    meson
    ninja
    pkg-config
    python3
    python3.pkgs.six
    python3.pkgs.pyparsing
  ];

  buildInputs = [
    alsa-lib
    cyrus_sasl
    glib
    gst_all_1.gst-plugins-base
    libXext
    libXfixes
    libXinerama
    libXrandr
    libXrender
    libcacard
    libjpeg
    libopus
    lz4
    openssl
    orc
    pixman
    python3.pkgs.pyparsing
    spice-protocol
    zlib
  ];

  NIX_CFLAGS_COMPILE = "-fno-stack-protector";

  mesonFlags = [
    "-Dgstreamer=1.0"
    "-Dcelt051=disabled"
  ];

  postInstall = ''
    ln -s spice-server $out/include/spice
    substituteInPlace $out/lib/pkgconfig/spice-server.pc \
      --replace UNKNOWN ${version}
  '';

  meta = with lib; {
    description = "Complete open source solution for interaction with virtualized desktop devices";
    longDescription = ''
      The Spice project aims to provide a complete open source solution for interaction
      with virtualized desktop devices.The Spice project deals with both the virtualized
      devices and the front-end. Interaction between front-end and back-end is done using
      VD-Interfaces. The VD-Interfaces (VDI) enable both ends of the solution to be easily
      utilized by a third-party component.
    '';
    homepage = "https://www.spice-space.org/";
    license = licenses.lgpl21;

    maintainers = [ maintainers.bluescreen303 ];
    platforms = platforms.linux;
  };
}
