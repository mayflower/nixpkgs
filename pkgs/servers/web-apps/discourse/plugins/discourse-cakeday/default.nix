{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-cakeday";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-cakeday";
    rev = "aebf07ed34776ea37eb3be0eb1b50920ff8b5b98";
    sha256 = "sha256-igH3jslHk0AKjH0qe3mpWHZ/oMO31MA8TVR5HMyFZc4=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-cakeday";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Show a birthday cake emoji beside the names of members on their join anniversary, or their actual birthday";
  };
}
