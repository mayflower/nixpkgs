{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig, xorg }:

stdenv.mkDerivation rec {
  name = "xininfo-${version}";
  version = "0.14.11";

  src = fetchFromGitHub {
    owner = "DaveDavenport";
    repo = "xininfo";
    rev = version;
    sha256 = "0lqwqv916ih3d688acyv0ndcgsi0wph9h99z81y0n36f86gbp04m";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig ];
  buildInputs = [ xorg.libxcb xorg.xcbutil xorg.xcbutilwm ];

  meta = {
    homepage = https://github.com/DaveDavenport/xininfo;
    description = "Small helper program for monitor layouts.";
    license = stdenv.lib.licenses.mit;
  };
}
