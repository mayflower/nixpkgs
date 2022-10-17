{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-push-notifications";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-push-notifications";
    rev = "cf4af535c82655e41e1383c1bd13eef52d5a4a4d";
    sha256 = "sha256-9SupfLlbsxravHaNf+fator11GuBDb359zbJCFZktCw=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-push-notifications";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Plugin for integrating Chrome and FireFox push notifications";
  };
}
