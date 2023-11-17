{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-footnote";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-footnote";
    rev = "6e9d97679acf65afd9abe5a1bd3281170895495a";
    sha256 = "sha256-TbDYGXG+PfxvzxYmLllWI83gzTaLcAe/vEHpIlzNZpE=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-footnote";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Allows users to create markdown footnotes in posts";
  };
}
