{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-assign";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-assign";
    rev = "8f04d82ae7048db5a7add0c6e380dcfe0a042f9f";
    sha256 = "sha256-elN4RuE3uNClx6CVBIpPbz3wzQ/Oy4fW8JiSpuLn+IE=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-docs";
    maintainers = with maintainers; [ dpausp ];
    license = licenses.mit;
    description = "Discourse Plugin for assigning users to a topic";
  };
}
