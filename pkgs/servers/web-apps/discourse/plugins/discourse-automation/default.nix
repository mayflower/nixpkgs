{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-automation";
  bundlerEnvArgs.gemdir = ./.;
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-automation";
    rev = "45bdde8bb95dc6da745b64dab1ae611a01ce776c";
    sha256 = "sha256-gQDi8FiD29j4NMoR9hkOBY7WAn7B0oFghlEtp8cRyOY=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-automation";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Lets you automate actions through scripts and triggers";
  };
}
