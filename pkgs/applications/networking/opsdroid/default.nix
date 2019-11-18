{ stdenv, fetchFromGitHub, pythonPackages, glibcLocales }:

pythonPackages.buildPythonApplication rec {
  pname = "opsdroid";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "opsdroid";
    repo = "opsdroid";
    rev = "v${version}";
    sha256 = "0bkagqjh1sqr9vhf9zvvig9w5anspmdwg7k2q9zzmfv4xgwiijg3";
  };

  disabled = !pythonPackages.isPy3k;

  #LC_ALL = "en_US.utf8";

  # tests folder is not included in release
  doCheck = false;

  #buildInputs = [ glibcLocales ];
  propagatedBuildInputs = with pythonPackages; [
    Babel opsdroid_get_image_size slackclient webexteamssdk bleach
    parse emoji puremagic yamale nbformat websockets pycron nbconvert
    aiohttp matrix-api-async aioredis aiosqlite arrow pyyaml motor
  ];

  postPatch = ''
    substituteInPlace requirements.txt \
      --replace slackclient==2.2.0 slackclient>=2.2.0 \
      --replace puremagic==1.5 puremagic>=1.5 \
      --replace aiohttp==3.6.1 aiohttp>=3.6.1
    substituteInPlace opsdroid/loader.py \
      --replace \
        'os.path.isfile(os.path.join(config["install_path"], "requirements.txt"))' \
        "False"

  '';

  meta = with stdenv.lib; {
    description = "An open source chat-ops bot framework";
    homepage = https://opsdroid.dev/;
    maintainers = with maintainers; [ fpletz globin willibutz ];
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
