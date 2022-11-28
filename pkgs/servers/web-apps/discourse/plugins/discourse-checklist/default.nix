{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-checklist";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-checklist";
    rev = "c8a14a66d1565e64ec3772ee418227bdba311bb1";
    sha256 = "sha256-DcyqNxQvGGYEOYyjzT75a1YwU2pWWWAn/5LQ78sR6P8=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-checklist";
    maintainers = with maintainers; [ ryantm ];
    license = licenses.gpl2Only;
    description = "A simple checklist rendering plugin for discourse ";
  };
}
