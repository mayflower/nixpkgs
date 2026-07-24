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
    rev = "67b4e52425ea571eb02c96ca29ab5dec50f3a897";
    sha256 = "sha256-Vg80Qvgt/KOkAw8/3SAJp2xTPIiM4ab34VTHOVTyw+w=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-apple-auth";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.gpl2;
    description = "Allows users to login using Apple authentication";
  };
}
