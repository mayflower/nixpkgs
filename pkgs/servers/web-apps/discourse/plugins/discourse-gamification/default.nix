{
  lib,
  mkDiscoursePlugin,
  fetchFromGitHub,
}:

mkDiscoursePlugin {
  name = "discourse-gamification";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-gamification";
    rev = "bea397c0b064522f2b4ff48a42aced2f0e4ef340";
    sha256 = "sha256-kaJqmQe6NIca+ODzu0AsmWKeyw694Rj643wokv5CDpY=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-gamification";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Adds customizable scoring (karma, kudos, points) and leaderboards to your instance";
  };
}
