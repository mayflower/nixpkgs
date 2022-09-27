{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-follow";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-follow";
    rev = "fd17ca74cd20bdb47e50dffe8b393dba5bf32e6f";
    sha256 = "sha256-Gohh0gWlvq+FhHQpmLAsKZaG46ow+Czrx5f98gTQ8Zc=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-follow";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.gpl2;
    description = "Allows you to follow other users, list the latest topics involving them and receive notifications when they post";
  };
}
