{
  lib,
  mkDiscoursePlugin,
  fetchFromGitHub,
}:

mkDiscoursePlugin {
  name = "discourse-whos-online";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-whos-online";
    rev = "623e947a518efd82be40e16cc204aa9511e0b701";
    sha256 = "sha256-pQLGUXxIKrECKqpKRtID2l2ISKy1Mru8jM7rNg605k4=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-whos-online";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Uses the messagebus to display a live list of active users";
  };
}
