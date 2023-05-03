{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-voting";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-voting";
    rev = "90e8fb9d76513482b62f9b2e9133e956311cbb26";
    sha256 = "sha256-D28xHFfvyYJZFgqB2K7ksw7BQVN6xcw/x5Chw8DsCMk=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-voting";
    maintainers = with maintainers; [ dpausp ];
    license = licenses.gpl2Only;
    description = "Adds the ability for voting on a topic within a specified category in Discourse";
  };
}
