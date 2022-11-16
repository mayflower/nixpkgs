{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-akismet";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-akismet";
    rev = "e2a257d54572aa67ad5507ed8ff7ee857b37745d";
    sha256 = "sha256-8zTJDssK6pH+GKlUGh+U3unB5CkreoBBl6kGH8IMRSs=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-akismet";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Allows you to fight spam with Akismet, an algorithm used by millions of sites to combat spam automatically.";
  };
}
