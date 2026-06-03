{
  lib,
  mkDiscoursePlugin,
  fetchFromGitHub,
}:

mkDiscoursePlugin {
  name = "discourse-patreon";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-patreon";
    rev = "5c1287fc51e20759f9307024c4d9fba4e525d790";
    sha256 = "sha256-JCrTYlSXXO3NAzNuUvDuJTRUM+83URe/Urff4FRmknQ=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-patreon";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Enable syncronization between Discourse Groups and Patreon rewards, and enable Patreon Social Login";
  };
}
