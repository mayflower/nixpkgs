{
  lib,
  mkDiscoursePlugin,
  fetchFromGitHub,
}:

mkDiscoursePlugin {
  name = "discourse-cakeday";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-cakeday";
    rev = "8c1a83c481c25deb69e9c25bb93ca667e7c251c4";
    sha256 = "sha256-aYXh0Np0OgkU78YwbkhObUKeW1GvbxQcuLxcNNdhIac=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-cakeday";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Show a birthday cake emoji beside the names of members on their join anniversary, or their actual birthday";
  };
}
