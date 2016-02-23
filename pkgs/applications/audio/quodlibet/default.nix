{ stdenv, fetchurl, python, buildPythonApplication, mutagen, pygtk, pygobject, intltool
{ stdenv, fetchurl, python, buildPythonPackage, mutagen, pygtk, pygobject, intltool
, pythonDBus, gst_python, wrapGAppsHook
, withGstPlugins ? true, gst_plugins_base ? null, gst_plugins_good ? null
, gst_plugins_ugly ? null, gst_plugins_bad ? null }:

assert withGstPlugins -> gst_plugins_base != null
                         || gst_plugins_good != null
                         || gst_plugins_ugly != null
                         || gst_plugins_bad != null;

let version = "2.6.3"; in

buildPythonApplication {
  # call the package quodlibet and just quodlibet
  name = "quodlibet-${version}"
         + stdenv.lib.optionalString withGstPlugins "-with-gst-plugins";
  namePrefix = "";

  # XXX, tests fail
  doCheck = false;

  srcs = [
    (fetchurl {
      url = "https://bitbucket.org/lazka/quodlibet-files/raw/default/releases/quodlibet-${version}.tar.gz";
      sha256 = "0ilasi4b0ay8r6v6ba209wsm80fq2nmzigzc5kvphrk71jwypx6z";
     })
    (fetchurl {
      url = "https://bitbucket.org/lazka/quodlibet-files/raw/default/releases/quodlibet-plugins-${version}.tar.gz";
      sha256 = "1rv08rhdjad8sjhplqsspcf4vkazgkxyshsqmbfbrrk5kvv57ybc";
     })
  ];

  preConfigure = ''
    # TODO: for now don't a apply gdist overrides, will be needed for shipping icons, gtk, etc
    sed -i /distclass/d setup.py
  '';

  sourceRoot = "quodlibet-${version}";

  postUnpack = ''
    # the patch searches for plugins in directory ../plugins
    # so link the appropriate directory there
    ln -sf quodlibet-plugins-${version} plugins
  '';

  patches = [ ./quodlibet-package-plugins.patch ];

  buildInputs = stdenv.lib.optionals withGstPlugins [
    gst_plugins_base gst_plugins_good gst_plugins_ugly gst_plugins_bad
  ] ++ stdenv.lib.optionals withGstPlugins [ wrapGAppsHook ];

  propagatedBuildInputs = [
    mutagen pygtk pygobject pythonDBus gst_python intltool
  ];

  meta = {
    description = "GTK+-based audio player written in Python, using the Mutagen tagging library";

    longDescription = ''
      Quod Libet is a GTK+-based audio player written in Python, using
      the Mutagen tagging library. It's designed around the idea that
      you know how to organize your music better than we do. It lets
      you make playlists based on regular expressions (don't worry,
      regular searches work too). It lets you display and edit any
      tags you want in the file. And it lets you do this for all the
      file formats it supports. Quod Libet easily scales to libraries
      of thousands (or even tens of thousands) of songs. It also
      supports most of the features you expect from a modern media
      player, like Unicode support, tag editing, Replay Gain, podcasts
      & internet radio, and all major audio formats.
    '';

    maintainers = [ stdenv.lib.maintainers.coroa ];
    homepage = http://code.google.com/p/quodlibet/;
  };
}
