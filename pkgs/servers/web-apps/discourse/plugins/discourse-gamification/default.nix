{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-gamification";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-gamification";
    rev = "a0fd3386ba0cc413470029d493e39241c1321ac9";
    sha256 = "sha256-J81y1B/UC5+ErdTu7VlRXmjuScP0DMGZfHNW72BDPxE=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-gamification";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Adds customizable scoring (karma, kudos, points) and leaderboards to your instance";
  };
}
