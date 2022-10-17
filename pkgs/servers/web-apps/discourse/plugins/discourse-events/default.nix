{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-events";
  bundlerEnvArgs.gemdir = ./.;
  src = fetchFromGitHub {
    owner = "paviliondev";
    repo = "discourse-events";
    rev = "0bd84303f441b01e8244d2d3a87f9f6c6d5b0601";
    sha256 = "sha256-zV071KWnq6P9MVkTEd5FmccbK3eEia4+eq3+tnJWLPw=";
  };
  meta = with lib; {
    homepage = "https://github.com/paviliondev/discourse-events";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.gpl2;
    description = "This plugin allows you to add and manage events with Discourse";
  };
}
