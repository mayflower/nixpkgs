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
    rev = "e2d6a1dd6f2af786404183d240605079df6d61e8";
    sha256 = "sha256-bKb2ogLbiHXCmCj0SYmHPjA8/o9EIg8VyaxiRa76eHs=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-tooltips";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Show tooltips around Discourse on hover, including topic previews";
  };
}
