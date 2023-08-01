{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-footnote";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-footnote";
    rev = "e671bb0764294fe2948bbd3a2e36e9026a40abe5";
    sha256 = "sha256-Tq0lYkTyqLa3P3L1XpoT+AiPzviJbx2uCqs2eoCwoQI=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-footnote";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Allows users to create markdown footnotes in posts";
  };
}
