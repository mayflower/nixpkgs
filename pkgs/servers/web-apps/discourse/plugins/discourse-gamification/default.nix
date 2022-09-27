{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-gamification";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-gamification";
    rev = "7407beae83ea31aea9dc3d232a7fa6157d9b9207";
    sha256 = "sha256-roFwZiSnLpNVZJhaMCGhboP9wNTiQoGUXHYlAWE0pR0=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-gamification";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Adds customizable scoring (karma, kudos, points) and leaderboards to your instance";
  };
}
