{
  lib,
  mkDiscoursePlugin,
  fetchFromGitHub,
}:

mkDiscoursePlugin {
  name = "discourse-adplugin";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-adplugin";
    rev = "bc68d6e23094300a9bac4f3899ebfa258799e021";
    sha256 = "sha256-SNXkrWa6ggsnllkbYWxREN1CzOH5HUI8IpgyooTrv5E=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-adplugin";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Official Discourse Advertising Plugin. Install & Start Serving Ads on Your Discourse Forum ";
  };
}
