{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-linkedin-auth";
  bundlerEnvArgs.gemdir = ./.;
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-linkedin-auth";
    rev = "89f6535ac79ffd7370976abf4d6cad497e7d86c4";
    sha256 = "sha256-cbcYUAnBiPHdZwisprfmqJVIXklmUADD+bLPJzi9+1Y=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-linkedin-auth";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.gpl2;
    description = "LinkedIn OAuth Login support for Discourse";
  };
}
