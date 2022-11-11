{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-push-notifications";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-push-notifications";
    rev = "7035f0fdf202d48ecc60e738fc437d40fd2cde73";
    sha256 = "sha256-Fml55AIQcWMSzNyubyi4GZEHzPgtAYKbWNK7SQMF4tI=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-push-notifications";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Plugin for integrating Chrome and FireFox push notifications";
  };
}
