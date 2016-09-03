{ fetchurl, stdenv, makeWrapper, python, alsaLib
, libX11, mesa_glu, SDL, lua5, zlib, bam, freetype
}:

stdenv.mkDerivation rec {
  name = "teeworlds-0.6.1";

  src = fetchurl {
    url = "http://www.teeworlds.com/files/${name}-source.tar.gz";
    sha256 = "025rcz59mdqksja4akn888c8avj9j28rk86vw7w1licdp67x8a33";
  };

  buildInputs = [
    python makeWrapper alsaLib libX11 mesa_glu SDL lua5 zlib bam freetype
  ];

  buildPhase = ''
    bam -a -v release
  '';

  installPhase = ''
    # Copy the graphics, sounds, etc.
    mkdir -p "$out/share/${name}"
    cp -rv data other/icons "$out/share/${name}"

    # Copy the executables (client, server, etc.).
    mkdir -p "$out/bin"
    executables=""
    for file in *
    do
      if [ -f "$file" ] && [ -x "$file" ]
      then
          executables="$file $executables"
      fi
    done
    cp -v $executables "$out/bin"

    # Make sure the programs are executed from the right directory so
    # that they can access the graphics and sounds.
    for program in $executables
    do
      wrapProgram $out/bin/$program \
        --run "cd $out/share/${name}"
    done

    # Copy the documentation.
    mkdir -p "$out/doc/${name}"
    cp -v *.txt "$out/doc/${name}"
  '';

  meta = {
    description = "Retro multiplayer shooter game";

    longDescription = ''
      Teeworlds is a free online multiplayer game, available for all
      major operating systems.  Battle with up to 12 players in a
      variety of game modes, including Team Deathmatch and Capture The
      Flag.  You can even design your own maps!
    '';

    homepage = http://teeworlds.com/;
    license = "BSD-style, see `license.txt'";
    maintainers = with stdenv.lib.maintainers; [ astsmtl ];
    platforms = with stdenv.lib.platforms; linux;
  };
}
