{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-tooltips";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-tooltips";
    rev = "d40dd5f7a5245a56c948fa7965752dad530e16fd";
    sha256 = "sha256-nogMeiBja9Z6LNChjT1csqwvD5931Wb8zjI4dK525M0=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-tooltips";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Show tooltips around Discourse on hover, including topic previews";
  };
}
