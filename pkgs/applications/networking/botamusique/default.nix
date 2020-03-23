{ stdenv, lib, fetchFromGitHub, python3, makeWrapper, ffmpeg, opusTools }:

let
  pymumble = fetchFromGitHub {
    owner = "azlux";
    repo = "pymumble";
    rev = "1dd6d6d4df2fdef33202f17e2acf3ba9678a5737";
    sha256 = "1r1sch8xrpbzffsb72lhp5xjr3ac3xb599n44vsfmaam3xklz6vz";
  };

  pythonEnv = python3.withPackages(ps: with ps; [
    opuslib
    protobuf
    flask
    youtube-dl
    python_magic
    pillow
    mutagen
    requests
    packaging
   ]);

in stdenv.mkDerivation rec {
  pname = "botamusique";
  version = "6.0";

  src = fetchFromGitHub {
    owner = "azlux";
    repo = "botamusique";
    rev = version;
    sha256 = "14qx840w2kixsaa9jdi27zgkz50vibaffdqlwqs3q1hiwv97x6cf";
  };

  dontBuild = true;
  doCheck = false;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ pythonEnv ];

  installPhase = ''
    mkdir -p $out/{bin,botamusique}
    cp -R ./* $out/botamusique/

    mkdir -p $out/botamusique/pymumble
    cp -R ${pymumble}/* $out/botamusique/pymumble

    chmod +x $out/botamusique/mumbleBot.py

    makeWrapper \
      $out/botamusique/mumbleBot.py $out/bin/botamusique \
      --prefix PATH : ${lib.makeBinPath [ pythonEnv ffmpeg opusTools ]}
  '';

  meta = with stdenv.lib; {
    description = "Bot to play youtube / soundcloud / radio / local music on Mumble (using pymumble).";
    homepage = https://github.com/azlux/botamusique;
    maintainers = with maintainers; [ elseym ];
    license = licenses.mit;
  };
}
