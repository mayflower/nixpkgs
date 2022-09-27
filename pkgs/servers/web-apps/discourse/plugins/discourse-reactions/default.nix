{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-reactions";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-reactions";
    rev = "301918a6505a89ae45481636987d9f5988d98805";
    sha256 = "sha256-VmBpA8xJ/gkC/eeZuV7u6T4mvprH3J9IoNZO0QD4IUI=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-reactions";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Allows users to react to a post from a choice of emojis, rather than only the like heart";
  };
}
