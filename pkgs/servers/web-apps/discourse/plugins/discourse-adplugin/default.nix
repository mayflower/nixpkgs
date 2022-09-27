{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-adplugin";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-adplugin";
    rev = "3b50a509f2a8bf54bf48e6f6dec8384a9ed9318d";
    sha256 = "sha256-K0xRiBtAyka54YwMgdrGQgMYYnOJ5GOxbRYBgldDUgM=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-adplugin";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Official Discourse Advertising Plugin. Install & Start Serving Ads on Your Discourse Forum ";
  };
}
