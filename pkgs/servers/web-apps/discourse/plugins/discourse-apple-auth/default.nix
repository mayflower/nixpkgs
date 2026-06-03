{
  lib,
  mkDiscoursePlugin,
  fetchFromGitHub,
}:

mkDiscoursePlugin {
  name = "discourse-apple-auth";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-apple-auth";
    rev = "6f6d350feff54c6d7daf43fac65a7a08e5e2250d";
    sha256 = "sha256-RY0e9sT+P6eoWg2woCQmewwGnNDA515SeBc3UsWtj3w=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-apple-auth";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.gpl2;
    description = "Allows users to login using Apple authentication";
  };
}
