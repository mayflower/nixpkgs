{ stdenv, fetchurl, pkgconfig, libvirt, glib, libxml2, intltool, libtool, yajl
, nettle, libgcrypt, pythonPackages, gobjectIntrospection, libcap_ng, numactl
, libapparmor
, xen ? null, enableXen ? false
}:

let
  inherit (pythonPackages) python pygobject2;
in stdenv.mkDerivation rec {
  name = "libvirt-glib-1.0.0";

  src = fetchurl {
    url = "http://libvirt.org/sources/glib/${name}.tar.gz";
    sha256 = "0iwa5sdbii52pjpdm5j37f67sdmf0kpcky4liwhy1nf43k85i4fa";
  };

  buildInputs = [
    pkgconfig libvirt glib libxml2 intltool libtool yajl nettle libgcrypt
    python pygobject2 gobjectIntrospection libcap_ng numactl libapparmor
  ] ++ stdenv.lib.optional enableXen xen;

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Library for working with virtual machines";
    longDescription = ''
      libvirt-glib wraps libvirt to provide a high-level object-oriented API better
      suited for glib-based applications, via three libraries:

      - libvirt-glib    - GLib main loop integration & misc helper APIs
      - libvirt-gconfig - GObjects for manipulating libvirt XML documents
      - libvirt-gobject - GObjects for managing libvirt objects
    '';
    homepage = http://libvirt.org/;
    license = licenses.lgpl2Plus;
    platforms = platforms.linux;
  };
}
