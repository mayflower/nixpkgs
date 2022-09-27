{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-whos-online";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-whos-online";
    rev = "43dec8b6f28fd5b1b4056bde3c21740ce534d816";
    sha256 = "sha256-a0VnRDdJ2+UpEUKv/9vHWFtBHHQNhNB2TEUzpkhXDqI=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-whos-online";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Uses the messagebus to display a live list of active users";
  };
}
