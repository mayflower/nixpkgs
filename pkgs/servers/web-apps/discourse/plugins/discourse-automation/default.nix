{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-automation";
  bundlerEnvArgs.gemdir = ./.;
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-automation";
    rev = "92c53622475cb4bf3e1a169045d31ddac2c89abb";
    sha256 = "sha256-Oopt7aRdGx2Z1LjPc15cXEeRHDI9zxfDVVPgVl1a/AE=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-automation";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Lets you automate actions through scripts and triggers";
  };
}
