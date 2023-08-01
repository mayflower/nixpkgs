{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-linkedin-auth";
  bundlerEnvArgs.gemdir = ./.;
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-linkedin-auth";
    rev = "1f3cf542bfa0cee28ea53fc90918b5d762b37ba1";
    sha256 = "sha256-zoZXYuyKovDUj0P54CKcVKJV0Mke9B5gzKfFZ9/4l74=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-linkedin-auth";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.gpl2;
    description = "LinkedIn OAuth Login support for Discourse";
  };
}
