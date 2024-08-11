{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-adplugin";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-adplugin";
    rev = "da38a4c053b68d7076db4441cfe86b473979945d";
    sha256 = "sha256-20mFQFSPTeV4E9vB/FMqeVzimmO0hVky7o/gYU32W/M=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-adplugin";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Official Discourse Advertising Plugin. Install & Start Serving Ads on Your Discourse Forum ";
  };
}
