{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-math";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-math";
    rev = "abe2daf0f30a4ffe94a17e46291cf6ae24050db7";
    sha256 = "sha256-e4WpRawSygHVM//hht2yiU6fnd/0jQp9LoqIFgbstr4=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-math";
    maintainers = with maintainers; [ talyz ];
    license = licenses.mit;
    description = "Official MathJax support for Discourse";
  };
}
