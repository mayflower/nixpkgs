{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-cakeday";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-cakeday";
    rev = "76fd231e1d7a71b3928eccdad0256372f0bcb793";
    sha256 = "sha256-QC7H5R/jodoRz7pt+IlXzKZtSsgcL+wZkznl1xV4LmM=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-cakeday";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Show a birthday cake emoji beside the names of members on their join anniversary, or their actual birthday";
  };
}
