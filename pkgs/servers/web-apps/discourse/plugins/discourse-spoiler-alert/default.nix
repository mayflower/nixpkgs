{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-spoiler-alert";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-spoiler-alert";
    rev = "686a058f27d9717b3b46a73b57a5078e1d0d05c7";
    sha256 = "sha256-VhN0JnSZnuwKWYu3jaFLW3DaOn+VNHF0PfN0bCmKamQ=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-spoiler-alert";
    maintainers = with maintainers; [ talyz ];
    license = licenses.mit;
    description = "Hide spoilers behind the spoiler-alert jQuery plugin";
  };
}
