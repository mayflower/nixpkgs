{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-canned-replies";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-canned-replies";
    rev = "354e1c001bbcf78691cc3e5b52fab30b94b6a16e";
    sha256 = "sha256-HJCDsx3wTETCqTr8mr4u9gWS/McMmEu7nPH8XDaSL+I=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-canned-replies";
    maintainers = with maintainers; [ talyz ];
    license = licenses.gpl2Only;
    description = "Adds support for inserting a canned reply into the composer window via a UI";
  };
}
