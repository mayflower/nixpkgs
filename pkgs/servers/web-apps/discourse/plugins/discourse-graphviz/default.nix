{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-graphviz";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-graphviz";
    rev = "df136294ebc0122a721eb9dc743ffee2256bc116";
    sha256 = "sha256-rO/4Tr5/P5AbVIoJrXFU4Q83bVVCvVgTlgMs3yLQT4U=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-graphviz";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Adds the Viz.js library to discourse";
  };
}
