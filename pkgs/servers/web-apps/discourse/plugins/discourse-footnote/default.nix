{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-footnote";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-footnote";
    rev = "1880424a128e999dc63fe359811986b9fca662f0";
    sha256 = "sha256-glWJv9LtxbwOsD4ufJckGfc6AGhwcah1izspBX5OPnw=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-footnote";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Allows users to create markdown footnotes in posts";
  };
}
