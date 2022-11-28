{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-push-notifications";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-push-notifications";
    rev = "87ffbf00e2c218ec42f69589ccfb17a78f6ad140";
    sha256 = "sha256-bXujBuJSMVrsJHGWnNi189IqvbjorhjYQ8ufP4ocI2A=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-push-notifications";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Plugin for integrating Chrome and FireFox push notifications";
  };
}
