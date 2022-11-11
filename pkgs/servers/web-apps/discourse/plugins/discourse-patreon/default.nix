{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-patreon";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-patreon";
    rev = "84433237db1467a2fd6de7e1ccf3885efad9dda2";
    sha256 = "sha256-ky7HL155ZlUgGhjqfjUYjLpWHYWKC14PIuxrCTAMMm4=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-patreon";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Enable syncronization between Discourse Groups and Patreon rewards, and enable Patreon Social Login";
  };
}
