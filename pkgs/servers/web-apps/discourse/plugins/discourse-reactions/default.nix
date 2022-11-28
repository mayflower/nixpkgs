{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-reactions";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-reactions";
    rev = "b63539b944a30a4fb525437d66f88d5cb1c682b0";
    sha256 = "sha256-c8m1I5jEJhTOkYEgWkMQxmE7qN9QZoAa/LLN8R4DHCM=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-reactions";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Allows users to react to a post from a choice of emojis, rather than only the like heart";
  };
}
