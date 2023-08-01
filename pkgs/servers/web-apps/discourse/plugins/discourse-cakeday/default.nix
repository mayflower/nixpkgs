{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-cakeday";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-cakeday";
    rev = "1fc3b4c1f67adf83d034000043d86feb933c90cd";
    sha256 = "sha256-NpTF6MR7ZR8cMpJGX0ma3L/K8MuAvjxIqd1x7dHaY3Q=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-cakeday";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Show a birthday cake emoji beside the names of members on their join anniversary, or their actual birthday";
  };
}
