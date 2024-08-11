{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-policy";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-policy";
    rev = "3547813fe0cf25b53b7ef035f5ca6b207767862f";
    sha256 = "sha256-+qCDeWVNX8ye+xTpbSzb7HgTo7n7n4FK5M//iJnsP1k=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-policy";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Confirm your users have seen or done something with reminders";
  };
}
