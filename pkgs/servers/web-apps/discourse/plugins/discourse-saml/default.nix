{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-saml";
  bundlerEnvArgs.gemdir = ./.;
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-saml";
    rev = "e095be116d7570252a769d8bd78235e295d742b3";
    sha256 = "sha256-LSMkBUj+00LgQl3KehqgsgT8+zlwsoHeJW0pcV9tTWM=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-saml";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Support for SAML in Discourse";
  };
}
