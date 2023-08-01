{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-gamification";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-gamification";
    rev = "6784b5dc4f041db4a1edc4f9f2020c4e0cea52ee";
    sha256 = "sha256-7NlAYRQTVGXhVSxREWYhesbsP8VYAkIHBfdtlbzqaVg=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-gamification";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Adds customizable scoring (karma, kudos, points) and leaderboards to your instance";
  };
}
