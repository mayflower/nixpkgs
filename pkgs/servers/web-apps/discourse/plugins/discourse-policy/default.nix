{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-policy";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-policy";
    rev = "3c5ba1f5476e77d2e156451a4ef32c4051096373";
    sha256 = "sha256-DENMhHwN+zH7adgDwas/Jqu+ET0LAIvipZZDR7jnX9U=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-policy";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Confirm your users have seen or done something with reminders";
  };
}
