{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-apple-auth";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-apple-auth";
    rev = "90ded63a964bd3e254c776ec59b5d6c5c2a439c7";
    sha256 = "sha256-gZ42jAy1SskFx0BiiCYw0qGr2DB7dafvvpfGn5qqQFU=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-apple-auth";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.gpl2;
    description = "Allows users to login using Apple authentication";
  };
}
