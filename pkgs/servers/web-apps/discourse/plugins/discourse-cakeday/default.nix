{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-cakeday";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-cakeday";
    rev = "6bf3b7057d3d08a5dbaeea4284521ab353932baf";
    sha256 = "sha256-azVSz1t0g0N5RO7P36fpqPiixvmBEnXZJYoUulWqxwI=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-cakeday";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Show a birthday cake emoji beside the names of members on their join anniversary, or their actual birthday";
  };
}
