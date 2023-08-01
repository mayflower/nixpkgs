{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-math";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-math";
    rev = "0d8f41759f2a7957486e02c9c5ea34160f6ac1f0";
    sha256 = "sha256-Qbns0lOS5B8uPoECLMMwfYHrSIvqEQmSXJsRhivMkds=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-math";
    maintainers = with maintainers; [ talyz ];
    license = licenses.mit;
    description = "Official MathJax support for Discourse";
  };
}
