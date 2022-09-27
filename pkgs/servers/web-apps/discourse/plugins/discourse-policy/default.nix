{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-policy";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-policy";
    rev = "76f5cd39e24630079d0aa18c9c4483296f4cb4d5";
    sha256 = "sha256-wdXCeQdbq6ja53fT3/gNxJNZKYkS7voxzL24mHhAsU4=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-policy";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Confirm your users have seen or done something with reminders";
  };
}
