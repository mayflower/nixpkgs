{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-graphviz";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-graphviz";
    rev = "3cd459bcd25e3fa2e56d3094c7e27e45f958e0c4";
    sha256 = "sha256-9ghZ4FpStgnnMhka5LU3cSnPFX9H6LI6UhexsxqZPY4=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-graphviz";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Adds the Viz.js library to discourse";
  };
}
