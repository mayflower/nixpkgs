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
    rev = "1db5217be8bdf83facd266b590bee1b66b0d2140";
    sha256 = "sha256-L1l5oebvzT2BZ3yxlmLdFBVMNnbvj2I0k02s4T1fycc=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-gamification";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Adds customizable scoring (karma, kudos, points) and leaderboards to your instance";
  };
}
