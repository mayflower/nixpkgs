{ stdenv
, fetchurl
, fetchpatch
, meson
, ninja
, pkgconfig
, gettext
, dbus
, glib
, libgudev
, udisks2
, libgcrypt
, libcap
, polkit
, libgphoto2
, avahi
, libarchive
, fuse
, libcdio
, libxml2
, libxslt
, docbook_xsl
, docbook_xml_dtd_42
, samba
, libmtp
, gnomeSupport ? false
, gnome3
, gcr
, glib-networking
, gnome-online-accounts
, wrapGAppsHook
, libimobiledevice
, libbluray
, libcdio-paranoia
, libnfs
, openssh
, libsecret
, libgdata
, python3
}:

stdenv.mkDerivation rec {
  pname = "gvfs";
  version = "1.40.2";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${stdenv.lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "07lpcfric3h0302n9b1pwa38mjb76r9s98kg2867y2d1qvzfivxx";
  };

  patches = [
    # CVE-2019-12448
    (fetchpatch {
      url = "https://gitlab.gnome.org/GNOME/gvfs/commit/a1c2e7ecab0d6457fa2227d92e3569c08516eac5.patch";
      sha256 = "03fwlpj1vbi80661bbhzv8ddx3czkzv9i1q4h3gqyxi5f1i0xfz4";
    })
    # CVE-2019-12447
    (fetchpatch {
      url = "https://gitlab.gnome.org/GNOME/gvfs/commit/0f25dea30d01d920443ab72b0c254560ec40e14c.patch";
      sha256 = "1p7c48nsx1lkv2qpkyrsm9qfa77xwd28gczwcpv2kbji3ws5qgj5";
    })
    (fetchpatch {
      url = "https://gitlab.gnome.org/GNOME/gvfs/commit/272e6bdac33309672955e8f8bf1b8f5f1e51fa0a.patch";
      sha256 = "0zxbhmgqxxw987ag8fh6yjzjn9jl55fqbn814jh9kwrk7x4prx9x";
    })
    # CVE-2019-12449
    (fetchpatch {
      url = "https://gitlab.gnome.org/GNOME/gvfs/commit/bed1e9685c9f65f6a3ff3b39dd8547db3e7e77f6.patch";
      sha256 = "0hfybfaz2gfx3yyw5ymx6q0pqwkx2r1i7gzprfp80bplwslq0d4h";
    })
    # CVE-2019-12795
    (fetchpatch {
      url = "https://gitlab.gnome.org/GNOME/gvfs/commit/e3808a1b4042761055b1d975333a8243d67b8bfe.patch";
      sha256 = "1lx6yxykx24mnq5izijqk744zj6rgww6ba76z0qjal4y0z3gsdqp";
    })
  ];

  postPatch = ''
    # patchShebangs requires executable file
    chmod +x meson_post_install.py
    patchShebangs meson_post_install.py
    patchShebangs test test-driver
  '';

  nativeBuildInputs = [
    meson
    ninja
    python3
    pkgconfig
    gettext
    wrapGAppsHook
    libxml2
    libxslt
    docbook_xsl
    docbook_xml_dtd_42
  ];

  buildInputs = [
    glib
    libgudev
    udisks2
    libgcrypt
    dbus
    libgphoto2
    avahi
    libarchive
    fuse
    libcdio
    samba
    libmtp
    libcap
    polkit
    libimobiledevice
    libbluray
    libcdio-paranoia
    libnfs
    openssh
    # TODO: a ligther version of libsoup to have FTP/HTTP support?
  ] ++ stdenv.lib.optionals gnomeSupport [
    gnome3.libsoup
    gcr
    glib-networking # TLS support
    gnome-online-accounts
    libsecret
    libgdata
  ];

  mesonFlags = [
    "-Dsystemduserunitdir=${placeholder "out"}/lib/systemd/user"
    "-Dtmpfilesdir=no"
  ] ++ stdenv.lib.optionals (!gnomeSupport) [
    "-Dgcr=false"
    "-Dgoa=false"
    "-Dkeyring=false"
    "-Dhttp=false"
    "-Dgoogle=false"
  ] ++ stdenv.lib.optionals (samba == null) [
    # Xfce don't want samba
    "-Dsmb=false"
  ];

  doCheck = false; # fails with "ModuleNotFoundError: No module named 'gi'"
  doInstallCheck = doCheck;

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
    };
  };

  meta = with stdenv.lib; {
    description = "Virtual Filesystem support library" + optionalString gnomeSupport " (full GNOME support)";
    license = licenses.lgpl2Plus;
    platforms = platforms.linux;
    maintainers = [ maintainers.lethalman ] ++ gnome3.maintainers;
  };
}
