{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-push-notifications";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-push-notifications";
    rev = "458414af456968cde60bdedd528bfd2def6a4783";
    sha256 = "sha256-dqxiIhSct/WePaitp0vfvDK8MR3G7vqO1y81YcRgedo=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-push-notifications";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Plugin for integrating Chrome and FireFox push notifications";
  };
}
