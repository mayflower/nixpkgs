{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-linkedin-auth";
  bundlerEnvArgs.gemdir = ./.;
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-linkedin-auth";
    rev = "8cc7a0d498b1152caaf076a4256596b252448189";
    sha256 = "sha256-eybp/cDDKEGgTyf9sywhTZCibgkFZ3LwUSmfPAS9oO0=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-linkedin-auth";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.gpl2;
    description = "LinkedIn OAuth Login support for Discourse";
  };
}
