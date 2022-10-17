{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-lti";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-lti";
    rev = "1fdfbeb799584b531c9f86efaff135d0c1e2ff10";
    sha256 = "sha256-qmxp/ysbCuaTaG0Vr1+pZAo+C/WB8OZEuFxV+25eKhU=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-lti";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "A plugin which allows Discourse to act as an Learning Tools Interoperability (1.3) Tool";
  };
}
