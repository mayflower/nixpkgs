{
  lib,
  mkDiscoursePlugin,
  fetchFromGitHub,
}:

mkDiscoursePlugin {
  name = "discourse-saml";
  bundlerEnvArgs.gemdir = ./.;
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-saml";
    rev = "e2044235dbdb217814d411e9637da31616928681";
    sha256 = "sha256-MPKsg3S56+G76Uw1Td5KgKeatQf31BdjYTyLOLgJ7hc=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-saml";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Support for SAML in Discourse";
  };
}
