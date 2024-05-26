{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-policy";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-policy";
    rev = "a9c7c38aadb32ec3561ca84062cebdd989481b3f";
    sha256 = "sha256-0IzTK7zMhf0YtJIxlzBXVQp1RCdO+K91MUbBcpMtZ8Q=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-policy";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Confirm your users have seen or done something with reminders";
  };
}
