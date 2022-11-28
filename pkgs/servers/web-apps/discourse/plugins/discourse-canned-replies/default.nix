{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-canned-replies";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-canned-replies";
    rev = "7bb7851997b5a29e0a51f695ad77578a43367c15";
    sha256 = "sha256-n3UR6am5FzM1aDhRnQT7fIN2kOwvrdHarno+YnW3fd4=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-canned-replies";
    maintainers = with maintainers; [ talyz ];
    license = licenses.gpl2Only;
    description = "Adds support for inserting a canned reply into the composer window via a UI";
  };
}
