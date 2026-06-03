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
    rev = "21058beddb898db53a367b8c906fe3375a5a0611";
    sha256 = "sha256-aNNM/2c3oMwCo9SF61t/q0s3CHiV7MBtCEaOufUChWM=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-lti";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "A plugin which allows Discourse to act as an Learning Tools Interoperability (1.3) Tool";
  };
}
