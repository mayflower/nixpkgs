{
  lib,
  mkDiscoursePlugin,
  fetchFromGitHub,
}:

mkDiscoursePlugin {
  name = "discourse-solved";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-solved";
    rev = "5450a5ef4e2ae35185320fc6af9678621026e148";
    sha256 = "sha256-Nqo7fX3VPxCqM3Y4OZAAzk9eSSiF4ol7ZqMjDv/qkvY=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-solved";
    maintainers = with maintainers; [ talyz ];
    license = licenses.mit;
    description = "Allow accepted answers on topics";
  };
}
