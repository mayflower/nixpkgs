{ stdenv, fetchFromGitHub, fetchpatch, pythonPackages }:

pythonPackages.buildPythonPackage rec {
  pname = "opsdroid";
  version = "0.20.1";

  src = fetchFromGitHub {
    owner = "opsdroid";
    repo = "opsdroid";
    rev = "v${version}";
    sha256 = "14yjw6bjrxchzgm80947vl58p6wm6x6zfjmh9g9wi29g3vhvir89";
  };

  disabled = !pythonPackages.isPy3k;

  # tests folder is not included in release
  doCheck = false;

  propagatedBuildInputs = with pythonPackages; [
    click Babel opsdroid_get_image_size slackclient webexteamssdk bleach
    parse emoji puremagic yamale nbformat websockets pycron nbconvert
    aiohttp matrix-api-async aioredis aiosqlite arrow pyyaml motor regex
    mattermostdriver setuptools voluptuous ibm-watson tailer multidict
    watchgod get-video-properties appdirs bitstring
  ];

  passthru.python = pythonPackages.python;

  meta = with stdenv.lib; {
    description = "An open source chat-ops bot framework";
    homepage = https://opsdroid.dev/;
    maintainers = with maintainers; [ fpletz globin willibutz lheckemann ];
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
