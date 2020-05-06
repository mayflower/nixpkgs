{ stdenv, fetchFromGitHub, fetchpatch, pythonPackages, glibcLocales }:

pythonPackages.buildPythonPackage rec {
  pname = "opsdroid";
  version = "0.17.1";

  src = fetchFromGitHub {
    owner = "opsdroid";
    repo = "opsdroid";
    rev = "v${version}";
    sha256 = "15jlm74ir3qvshwkns856hhjhcp000zryh85bcj27dfnn6jn6snn";
  };

  disabled = !pythonPackages.isPy3k;

  # tests folder is not included in release
  doCheck = false;

  propagatedBuildInputs = with pythonPackages; [
    Babel opsdroid_get_image_size slackclient webexteamssdk bleach
    parse emoji puremagic yamale nbformat websockets pycron nbconvert
    aiohttp matrix-api-async aioredis aiosqlite arrow pyyaml motor
    mattermostdriver setuptools voluptuous ibm-watson tailer multidict
  ];

  patches = [
    # fixes shell connector, remove >0.17.1
    (fetchpatch {
      url = "https://github.com/opsdroid/opsdroid/commit/9c6eb3af14a2b5cd2ac875153d3707a490b48150.patch";
      sha256 = "06gdlb6ysdg5w7m848k61bjqqnrrr3q82avkh9dv71nh4fqi6gv2";
    })
  ];

  postPatch = ''
    substituteInPlace requirements.txt \
      --replace arrow==0.15.4 arrow>=0.15.4 \
      --replace certifi==2019.11.28 certifi>=2019.11.28 \
      --replace tailer==0.4.1 tailer>=0.4.1 \
      --replace aioredis==1.3.1 aioredis>=1.3.1 \
      --replace pyyaml==5.2 pyyaml>=5.2 \
      --replace ibm-watson==4.0.1 ibm-watson>=4.0.1 \
      --replace websockets==8.1 websockets>=8.1 \
      --replace slackclient==2.5.0 slackclient>=2.5.0 \
      --replace nbconvert==5.6.1 nbconvert>=5.6.1 \
      --replace multidict==4.7.1 multidict>=4.7.1 \
      --replace nbformat==4.4.0 nbformat>=4.4.0 \
      --replace aiosqlite==0.10.0 aiosqlite>=0.10.0 \
      ;
    sed -i '/setuptools=/d' requirements.txt
    substituteInPlace opsdroid/loader.py \
      --replace \
        'os.path.isfile(os.path.join(config["install_path"], "requirements.txt"))' \
        "False"

  '';

  meta = with stdenv.lib; {
    description = "An open source chat-ops bot framework";
    homepage = https://opsdroid.dev/;
    maintainers = with maintainers; [ fpletz globin willibutz lheckemann ];
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
