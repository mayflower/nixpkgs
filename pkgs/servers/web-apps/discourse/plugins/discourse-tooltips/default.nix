{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-tooltips";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-tooltips";
    rev = "1b9db36638ab497954b369c1dc69940dcf524825";
    sha256 = "sha256-6iM7X8Lrt39Xfz+1ZOzh69IZsLFIYDecmSRVJqolFWI=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-tooltips";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Show tooltips around Discourse on hover, including topic previews";
  };
}
