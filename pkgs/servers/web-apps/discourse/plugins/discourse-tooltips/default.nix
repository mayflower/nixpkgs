{
  lib,
  mkDiscoursePlugin,
  fetchFromGitHub,
}:

mkDiscoursePlugin {
  name = "discourse-tooltips";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-tooltips";
    rev = "da2ef0b16a8c2e42b8db34f2a720ac8c7e1e5577";
    sha256 = "sha256-OoaueHaNKnqxl1o31FkoRgdgRAgnhsqxmuAEm4Yol4c=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-tooltips";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Show tooltips around Discourse on hover, including topic previews";
  };
}
