{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-push-notifications";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-push-notifications";
    rev = "2aea8db27304b4c2a663ab258786af883c36c44f";
    sha256 = "sha256-nv486TP7i7SOJi5Vc9NbKba3cdjkHaZ/fWeg6CpBzQc=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-push-notifications";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Plugin for integrating Chrome and FireFox push notifications";
  };
}
