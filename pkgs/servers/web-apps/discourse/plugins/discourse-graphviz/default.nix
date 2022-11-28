{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-graphviz";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-graphviz";
    rev = "4b20e8589a759ee20862164cfb0d3f9a72df9205";
    sha256 = "sha256-p/H4GZHUWDmWkSuXC0ujYJSqFLOWHqMFktRosvwXQRc=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-graphviz";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Adds the Viz.js library to discourse";
  };
}
