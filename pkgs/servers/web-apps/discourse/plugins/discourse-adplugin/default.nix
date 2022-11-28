{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-adplugin";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-adplugin";
    rev = "fd6ac11ee9c32362f5b0675e826e92aac0628ccb";
    sha256 = "sha256-NVD3vjTxdLZfCh/v4EHAHkuDpvL1IrkWkx1yAHOdRRc=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-adplugin";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Official Discourse Advertising Plugin. Install & Start Serving Ads on Your Discourse Forum ";
  };
}
