{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-policy";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-policy";
    rev = "80be142a78b44373c01385bc1edb2f32ddd029e1";
    sha256 = "sha256-H0nYQEyMS22pEEBdMW8K2sP3laBoOzu/ndRlRqlZQyw=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-policy";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Confirm your users have seen or done something with reminders";
  };
}
