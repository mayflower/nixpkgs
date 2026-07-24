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
    rev = "5e7c58fc2f672fc0c4c9380f856cf92f3e247b10";
    sha256 = "sha256-nW8ptWIPxcViFLS6LyXY9M1r3OC1qeeU4o+BMrZda4k=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-patreon";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Enable syncronization between Discourse Groups and Patreon rewards, and enable Patreon Social Login";
  };
}
