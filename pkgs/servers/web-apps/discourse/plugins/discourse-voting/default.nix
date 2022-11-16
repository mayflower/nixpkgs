{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-voting";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-voting";
    rev = "500c1b7d356bead9f3a391588dfa4c69dadd93e9";
    sha256 = "sha256-/fjY6GDGxZHnvrzFW3gZ8yhVrE5wiMz4Rk4/SuY/pVM=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-voting";
    maintainers = with maintainers; [ dpausp ];
    license = licenses.gpl2Only;
    description = "Adds the ability for voting on a topic within a specified category in Discourse";
  };
}
