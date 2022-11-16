{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-automation";
  bundlerEnvArgs.gemdir = ./.;
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-automation";
    rev = "8cd9649df43d15c2e9456240851f0aed957b62ba";
    sha256 = "sha256-sWTwYlWuWSEkQFn652Q2Ok2K4VfwPuXiV+rxAnsjSis=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-automation";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Lets you automate actions through scripts and triggers";
  };
}
