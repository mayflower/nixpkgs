{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-whos-online";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-whos-online";
    rev = "ef021c3f3ce1b0999f356ff010cc4c51e3dc66c4";
    sha256 = "sha256-nUoIFzaGAUkH/DaJv8Xtjq3e/f2zNnOxB5vfUl1a9gE=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-whos-online";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Uses the messagebus to display a live list of active users";
  };
}
