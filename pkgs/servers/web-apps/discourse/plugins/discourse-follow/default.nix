{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-follow";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-follow";
    rev = "d979deca04d96279c3f22c7b58dee14bf0d71b90";
    sha256 = "sha256-mVHYByzWLk1wlVWvqrVBBvp14YILo7lUydwRxhHG2iM=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-follow";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.gpl2;
    description = "Allows you to follow other users, list the latest topics involving them and receive notifications when they post";
  };
}
