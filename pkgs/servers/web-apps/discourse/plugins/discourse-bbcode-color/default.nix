{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-bbcode-color";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-bbcode-color";
    rev = "57d094ecfa2c2d92a18821471e463490d975097f";
    sha256 = "sha256-7dHGCkCnvlcg+s91NpymJms6ZCufqFblDNu4F2XUHkQ=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-bbcode-color";
    maintainers = with maintainers; [ ryantm ];
    license = licenses.mit;
    description = "Support BBCode color tags.";
  };
}
