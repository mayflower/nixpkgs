{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-lti";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-lti";
    rev = "1949ddf3061b5d152afad3abd7cb1d0df13973bb";
    sha256 = "sha256-zruzRzAolQ3yZCXG+SVzmVMcwgpuLfYiL8pgQzIDtvg=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-lti";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "A plugin which allows Discourse to act as an Learning Tools Interoperability (1.3) Tool";
  };
}
