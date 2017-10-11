{ stdenv, fetchFromGitHub, xclip, xininfo, makeWrapper, maim, imgurbash2 }:

stdenv.mkDerivation rec {
  name = "teiler-${version}";
  version = "3.1.1+git20170902";

  src = fetchFromGitHub {
    owner = "carnager";
    repo = "teiler";
    rev = "4143ed69009e0b5c08edc264de75a14b6e996a31";
    sha256 = "0clf0vi3qc2hirsab9l4bh44ql9y6xclpf4y005vc52ln6w8mq9r";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  preInstall = ''
    makeFlags="PREFIX= DESTDIR=$out"
    substituteInPlace ./teiler \
      --replace "cp /etc/teiler/teiler.conf " "cp --no-preserve=mode /etc/teiler/teiler.conf "  \
      --replace " /etc" " $out/etc"
  '';

  postInstall = ''
    wrapProgram $out/bin/teiler \
      --prefix PATH : ${stdenv.lib.makeBinPath [xclip xininfo maim imgurbash2]}
  '';

  meta = {
    homepage = https://github.com/carnager/teiler;
    description = "Little script for screenshots and screencasts utilizing rofi, maim, ffmpeg";
    license = stdenv.lib.licenses.gpl3;
  };
}
