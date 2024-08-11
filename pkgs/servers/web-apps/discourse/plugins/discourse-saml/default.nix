{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-saml";
  bundlerEnvArgs.gemdir = ./.;
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-saml";
    rev = "d59be6e624a530d16d03ae7d6da2f14dd526267c";
    sha256 = "sha256-5vP1RctUe2m7LPFvXlzS1CuZgPrDi04npmi1KgpdxHw=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-saml";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Support for SAML in Discourse";
  };
}
