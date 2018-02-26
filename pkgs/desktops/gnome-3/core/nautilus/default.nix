{ stdenv, fetchurl, meson, ninja, pkgconfig, gettext, libxml2, desktop-file-utils, wrapGAppsHook
, gtk, gnome3, gnome-autoar, glib, dbus-glib, shared-mime-info, libnotify, libexif
, exempi, librsvg, tracker, tracker-miners, libselinux, gdk_pixbuf }:

stdenv.mkDerivation rec {
  inherit (import ./src.nix fetchurl) name src;

  nativeBuildInputs = [ meson ninja pkgconfig libxml2 gettext wrapGAppsHook desktop-file-utils ];

  buildInputs = [ dbus-glib shared-mime-info libexif gtk exempi libnotify libselinux
                  tracker tracker-miners gnome3.gnome-desktop gnome3.adwaita-icon-theme
                  gnome3.gsettings-desktop-schemas ];

  propagatedBuildInputs = [ gnome-autoar ];

  # fatal error: gio/gunixinputstream.h: No such file or directory
  NIX_CFLAGS_COMPILE = "-I${glib.dev}/include/gio-unix-2.0";

  preFixup = ''
    gappsWrapperArgs+=(
      # Thumbnailers
      --prefix XDG_DATA_DIRS : "${gdk_pixbuf}/share"
      --prefix XDG_DATA_DIRS : "${librsvg}/share"
      --prefix XDG_DATA_DIRS : "${shared-mime-info}/share"
    )
  '';

#  hardeningDisable = [ "format" ];
  enableParallelBuilding = true;

  postPatch = ''
    patchShebangs build-aux/meson/postinstall.py
  '';

  patches = [ ./extension_dir.patch ];

  meta = with stdenv.lib; {
    platforms = platforms.linux;
    maintainers = gnome3.maintainers;
  };
}
