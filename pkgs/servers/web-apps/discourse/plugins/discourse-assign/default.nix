{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-assign";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-assign";
    rev = "969ee0e70a1bc5bc52b34f1bcf8f4af21e38cca4";
    sha256 = "sha256-UIasyX6h/vp+X0qo5Hrtau1GUml1cUvWyS9GQk2gwWM=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-docs";
    maintainers = with maintainers; [ dpausp ];
    license = licenses.mit;
    description = "Discourse Plugin for assigning users to a topic";
  };
}
