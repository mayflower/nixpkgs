{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-akismet";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-akismet";
    rev = "c11e7a4f79c3c29dd75978ab997af639166e21e4";
    sha256 = "sha256-E5AidttfnaRp87OTNg6tU80oDoVU9W9VvlfpY1fV/tI=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-akismet";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Allows you to fight spam with Akismet, an algorithm used by millions of sites to combat spam automatically.";
  };
}
