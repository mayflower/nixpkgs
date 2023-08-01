{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-graphviz";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-graphviz";
    rev = "b59eeffbbab20accfa4d83c64c13a9b9d8df2aaf";
    sha256 = "sha256-TprBGas7IXj6PmMT2kFGbLpo5EpZiFMZXAWW/uTv6UU=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-graphviz";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Adds the Viz.js library to discourse";
  };
}
