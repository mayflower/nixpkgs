{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-apple-auth";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-apple-auth";
    rev = "f065053b3ac79a410261aee8eab4965a22809c01";
    sha256 = "sha256-WTKKdLOQs/yzUR8W91Gi3BMHCHUnBtdS1sS6ShFx0Mc=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-apple-auth";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.gpl2;
    description = "Allows users to login using Apple authentication";
  };
}
