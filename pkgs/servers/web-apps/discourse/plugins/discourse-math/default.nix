{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-math";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-math";
    rev = "321a8c41f9f5918b4063a37353d790139d2a14e9";
    sha256 = "sha256-hAlARX0gOHOXoZ/3pUbt1kzC7bzu5yJtf/2IKDf3RFs=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-math";
    maintainers = with maintainers; [ talyz ];
    license = licenses.mit;
    description = "Official MathJax support for Discourse";
  };
}
