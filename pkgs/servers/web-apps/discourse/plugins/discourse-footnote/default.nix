{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-footnote";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-footnote";
    rev = "ff88274febeb696a594cb399fac8fb9122535f2f";
    sha256 = "sha256-d37xOpDnrHq579cfpTKyTCZLgm9afJOEevyUIxaCZrc=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-footnote";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Allows users to create markdown footnotes in posts";
  };
}
