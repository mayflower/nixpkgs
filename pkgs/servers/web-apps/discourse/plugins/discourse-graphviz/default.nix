{
  lib,
  mkDiscoursePlugin,
  fetchFromGitHub,
}:

mkDiscoursePlugin {
  name = "discourse-graphviz";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-graphviz";
    rev = "ce5d278086e9959ce02eb8d543b0577d04eda659";
    sha256 = "sha256-ETG17LZbxk6Ja4Ycq7n5puRHf1+HNwLnWWDxkNQiaKs=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-graphviz";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Adds the Viz.js library to discourse";
  };
}
