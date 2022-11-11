{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-lti";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-lti";
    rev = "48d0f2d27ea528db4a29bf7be490a982c947ea25";
    sha256 = "sha256-j0ke4cCb9HlsmrIKGtXrYjVedDCabV1Amfia8zZX4kQ=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-lti";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "A plugin which allows Discourse to act as an Learning Tools Interoperability (1.3) Tool";
  };
}
