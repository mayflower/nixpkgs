{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-solved";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-solved";
    rev = "e4b610b676bb39ae09ff8e65db1eb0434124a6b2";
    sha256 = "sha256-h5Sn6kY5ERuYgDODO8BU9SrOyy8lWoAcrZxxNfrTQyo=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-solved";
    maintainers = with maintainers; [ talyz ];
    license = licenses.mit;
    description = "Allow accepted answers on topics";
  };
}
