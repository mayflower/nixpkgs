{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-assign";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-assign";
    rev = "aec66333f44f5783500977c23798999b10a70c6d";
    sha256 = "sha256-hv45RHBblRzsjfuTwqZgRiB9RZ0z9F4sNOcTrWjy23I=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-docs";
    maintainers = with maintainers; [ dpausp ];
    license = licenses.mit;
    description = "Discourse Plugin for assigning users to a topic";
  };
}
