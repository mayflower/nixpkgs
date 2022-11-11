{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-linkedin-auth";
  bundlerEnvArgs.gemdir = ./.;
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-linkedin-auth";
    rev = "df7a1666b5441d76e7c0aa40cf5691b4154854e8";
    sha256 = "sha256-4LfmnmOpbeWoijEHZdHDzLIr4V24EdambcrXkpL0oaE=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-linkedin-auth";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.gpl2;
    description = "LinkedIn OAuth Login support for Discourse";
  };
}
