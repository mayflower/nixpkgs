{ stdenv, fetchurl, pkgconfig, file, expat
, disableLibraries ? false, libffi ? null
, disableDocumentation ? true, doxygen ? null, xmlto ? null, graphviz ? null
, docbook5_xsl ? null, docbook_xml_xslt ? null, libxslt ? null
, withHostScanner ? null
}:

assert (disableLibraries) -> (withHostScanner == null);
assert (!disableLibraries) -> (libffi != null);
assert (!disableDocumentation) -> (doxygen != null && xmlto != null
&& graphviz != null && docbook5_xsl != null && docbook_xml_xslt != null
&& libxslt != null);

with stdenv.lib;
stdenv.mkDerivation rec {
  name = "wayland-${if disableLibraries then "scanner-" else ""}${version}";
  version = "1.9.0";

  src = fetchurl {
    url = "http://wayland.freedesktop.org/releases/wayland-${version}.tar.xz";
    sha256 = "1yhy62vkbq8j8c9zaa6yzvn75cd99kfa8n2zfdwl80x019r711ww";
  };

  preConfigure = ''
    substituteInPlace ./configure --replace /usr/bin/file ${file}/bin/file
  '';

  configureFlags = [ ]
    ++ optional disableLibraries "--disable-libraries"
    ++ optional disableDocumentation "--disable-documentation"
    ++ optional (withHostScanner != null) "--with-host-scanner";

  nativeBuildInputs = [ pkgconfig file ]
    ++ optional (withHostScanner != null) withHostScanner;

  buildInputs = [ expat ]
    ++ optional (!disableLibraries) libffi
    ++ optionals (!disableDocumentation) [
      doxygen xmlto graphviz docbook5_xsl docbook_xml_xslt libxslt
    ];

  # there are no tests for wayland-scanner
  doCheck = (if withHostScanner != null then true else false);

  meta = {
    description = "Reference implementation of the wayland protocol";
    homepage    = http://wayland.freedesktop.org/;
    license     = licenses.mit;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ codyopel wkennington calbrecht ];
  };
}
