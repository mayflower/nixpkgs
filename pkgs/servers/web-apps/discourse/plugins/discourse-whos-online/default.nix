{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-whos-online";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-whos-online";
    rev = "45e84584eee7263a587785b42bab140c0471fbd5";
    sha256 = "sha256-TYUShe+QQZtnGy/Tv+TmEPJdYwAeQ0zgWkkhzZrwwFE=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-whos-online";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Uses the messagebus to display a live list of active users";
  };
}
