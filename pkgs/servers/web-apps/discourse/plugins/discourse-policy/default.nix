{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-policy";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-policy";
    rev = "3cf65b9ecd155f8c9e3491d6aecb4013f1a80b37";
    sha256 = "sha256-qD4FKr8+gljq9PrHxbWu9IZPssCuR4OvoEvIcKbcXbI=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-policy";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Confirm your users have seen or done something with reminders";
  };
}
