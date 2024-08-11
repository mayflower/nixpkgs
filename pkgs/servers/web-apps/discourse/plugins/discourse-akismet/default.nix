{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-akismet";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-akismet";
    rev = "d891cbab28c9692f205d5c99610e9c364018b976";
    sha256 = "sha256-GuPxZ+bsWAhU4QFIrg2cOfJzDcKjCPLeUlur7OWTyx8=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-akismet";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Allows you to fight spam with Akismet, an algorithm used by millions of sites to combat spam automatically.";
  };
}
