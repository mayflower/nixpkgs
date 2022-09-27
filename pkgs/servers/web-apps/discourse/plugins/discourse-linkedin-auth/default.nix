{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-linkedin-auth";
  bundlerEnvArgs.gemdir = ./.;
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-linkedin-auth";
    rev = "5ba3ae4df194affd105736388f33fd600678057f";
    sha256 = "sha256-zXyLZ3B2tXWtHo9tWpou4lDzcKvxtTuMm+CmJhKQhWU=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-linkedin-auth";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.gpl2;
    description = "LinkedIn OAuth Login support for Discourse";
  };
}
