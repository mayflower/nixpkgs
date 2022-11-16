{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-github";
  bundlerEnvArgs.gemdir = ./.;
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-github";
    rev = "b98d4128e1e9f2b9e263346cb00d37548da7a20b";
    sha256 = "sha256-ZPMZEqqYevFKzdYQBPdCSBcPFpCYl76dj5UMh92Sgfg=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-github";
    maintainers = with maintainers; [ talyz ];
    license = licenses.mit;
    description = "Adds GitHub badges and linkback functionality";
  };

}
