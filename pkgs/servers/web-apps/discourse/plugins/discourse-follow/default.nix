{
  lib,
  mkDiscoursePlugin,
  fetchFromGitHub,
}:

mkDiscoursePlugin {
  name = "discourse-follow";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-follow";
    rev = "33e2f75cfd0c3e749a7ae59a451e6fd99c38e726";
    sha256 = "sha256-0Fze2svWAg+SNdD1boHjBtDACVy0ELwBCrilBScfYw8=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-follow";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.gpl2;
    description = "Allows you to follow other users, list the latest topics involving them and receive notifications when they post";
  };
}
