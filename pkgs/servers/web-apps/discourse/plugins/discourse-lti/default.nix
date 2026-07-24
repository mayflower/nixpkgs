{
  lib,
  mkDiscoursePlugin,
  fetchFromGitHub,
}:

mkDiscoursePlugin {
  name = "discourse-lti";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-lti";
    rev = "164f15b4ee31ffd879b9896b788e114c4dbf6cac";
    sha256 = "sha256-yAq4ADZdK9knfMLqfxwMJ+Vb3lKD/uvp99lQrI9zs8k=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-lti";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "A plugin which allows Discourse to act as an Learning Tools Interoperability (1.3) Tool";
  };
}
