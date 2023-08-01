{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-adplugin";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-adplugin";
    rev = "8cb9628f0d02ee8ec3b67d18fa2017e6c77907e5";
    sha256 = "sha256-MRFw19+HruKCLWz7PyGeVZxAmzGDQAZP0Ne+e580ZR8=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-adplugin";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Official Discourse Advertising Plugin. Install & Start Serving Ads on Your Discourse Forum ";
  };
}
