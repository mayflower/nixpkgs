{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-events";
  bundlerEnvArgs.gemdir = ./.;
  src = fetchFromGitHub {
    owner = "paviliondev";
    repo = "discourse-events";
    rev = "e291d766d06feb71a93de8de5cba0be9c0657f25";
    sha256 = "sha256-aTNES7qVWLxRBNTSgRYW8c2eQJjP7IpZCSc5d8pDNls=";
  };
  meta = with lib; {
    homepage = "https://github.com/paviliondev/discourse-events";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.gpl2;
    description = "This plugin allows you to add and manage events with Discourse";
  };
}
