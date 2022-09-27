{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-patreon";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-patreon";
    rev = "ff349342c9d9d1ba79e63c847d29edcb9e80869b";
    sha256 = "sha256-/FAml1WvIy/+i4GvEfmf9/H0rC2RmcwK/3KWQ4mWvo0=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-patreon";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Enable syncronization between Discourse Groups and Patreon rewards, and enable Patreon Social Login";
  };
}
