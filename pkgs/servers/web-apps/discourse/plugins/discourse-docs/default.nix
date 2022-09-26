{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-docs";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-docs";
    rev = "1fe484e1dc176b3b75e8f9f64d5f7767a9e3918f";
    sha256 = "sha256-SLm5Nf/qxrWYfMfpqA4zJ0uQwm8idPkARSii7bn1Asw=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-docs";
    maintainers = with maintainers; [ dpausp ];
    license = licenses.mit;
    description = "Find and filter knowledge base topics";
  };
}
