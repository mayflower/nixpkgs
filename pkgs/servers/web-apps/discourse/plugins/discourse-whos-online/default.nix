{
  lib,
  mkDiscoursePlugin,
  fetchFromGitHub,
}:

mkDiscoursePlugin {
  name = "discourse-whos-online";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-whos-online";
    rev = "dd7baa71569b894ec6a14843c6f6c0f3a0179ccb";
    sha256 = "sha256-OFX0JUVacY0ETTBlqS0iP53FWeefWl57Yk91z60vTJ8=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-whos-online";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Uses the messagebus to display a live list of active users";
  };
}
