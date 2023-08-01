{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-whos-online";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-whos-online";
    rev = "b429e927a8fdd770098635df6592b69d5d020d27";
    sha256 = "sha256-Veb3VqtyE0Z0uGEJosMwdEVcBWdRjSjtFLS0p7LMBfc=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-whos-online";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Uses the messagebus to display a live list of active users";
  };
}
