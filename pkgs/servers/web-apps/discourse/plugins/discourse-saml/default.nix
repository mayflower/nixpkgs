{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-saml";
  bundlerEnvArgs.gemdir = ./.;
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-saml";
    rev = "15a8274bbec438768fb020d4f20462db476b0f29";
    sha256 = "sha256-26Wd1MJc5AWhaxd4cfugp1SaEz+LF8ns8TnvAN9mZs8=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-saml";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Support for SAML in Discourse";
  };
}
