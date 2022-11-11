{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-akismet";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-akismet";
    rev = "a365a20aee7f320999d6b93c892d34d1a77961a4";
    sha256 = "sha256-mpxuY72kfH4hl4dr7ZWZ2t09wPnfISPUf1wIdm+ich4=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-akismet";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Allows you to fight spam with Akismet, an algorithm used by millions of sites to combat spam automatically.";
  };
}
