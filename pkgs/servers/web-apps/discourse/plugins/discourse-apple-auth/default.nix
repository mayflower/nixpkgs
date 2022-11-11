{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-apple-auth";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-apple-auth";
    rev = "c65e324c0787002a813bc06360839b760298db7d";
    sha256 = "sha256-31ikbKbT4GKVjf1rXYHJ1Iiz+CbU66ZTB+IDT8LFsNo=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-apple-auth";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.gpl2;
    description = "Allows users to login using Apple authentication";
  };
}
