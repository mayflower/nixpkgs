{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-bbcode-color";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-bbcode-color";
    rev = "9418602c6636372db07edc5827a16952f9bbd3db";
    sha256 = "sha256-YRk/oRBS7Ms4+E/CYTAhfG5Sml8CCG5/fPQCkpBkOsQ=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-bbcode-color";
    maintainers = with maintainers; [ ryantm ];
    license = licenses.mit;
    description = "Support BBCode color tags.";
  };
}
