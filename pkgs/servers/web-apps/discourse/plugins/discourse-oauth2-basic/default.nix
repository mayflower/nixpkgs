{
  lib,
  mkDiscoursePlugin,
  fetchFromGitHub,
}:

mkDiscoursePlugin rec {
  name = "discourse-oauth2-basic";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = name;
    rev = "6de97fb641cec8a868153c58b0268aee0c3c33d5";
    sha256 = "sha256-k7GCuKlrgjtijMhMJIoi/OWRQS1MsAHKbwy1A+ZxBVI=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/${name}";
    maintainers = with maintainers; [ ehmry ];
    license = licenses.mit;
    description = "Basic OAuth2 plugin for use with Discourse";
  };
}
