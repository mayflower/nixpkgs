{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-footnote";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-footnote";
    rev = "6dfbc02a1192173fab4c6bdf0e660ea5a7615bcb";
    sha256 = "sha256-VU/C9Tft8u/6bWaV0SiDfx7+RNcQyby+oe/yC+HUivA=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-footnote";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Allows users to create markdown footnotes in posts";
  };
}
