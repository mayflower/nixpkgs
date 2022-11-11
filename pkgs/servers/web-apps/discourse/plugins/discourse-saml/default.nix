{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-saml";
  bundlerEnvArgs.gemdir = ./.;
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-saml";
    rev = "79f52a7a5d98598ac9b0b4f30436ac33fc93f6b2";
    sha256 = "sha256-Kdtr1l8N8dAnB0sxTWa4ZQmPOinpvWrV7hytF4N2Uyg=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-saml";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Support for SAML in Discourse";
  };
}
