{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-chat-integration";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-chat-integration";
    rev = "ba40ede510986f74a23345082ac578e126467b97";
    sha256 = "sha256-oo+HH6JC+BbPWFOBAflIZOG6tSmbxPv1SlWAHU0qhAg=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-chat-integration";
    maintainers = with maintainers; [ dpausp ];
    license = licenses.mit;
    description = "This plugin integrates Discourse with a number of external chatroom systems";
  };
}
