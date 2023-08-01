{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-yearly-review";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-yearly-review";
    rev = "b4978ba5389fe366e1a788007088e7aeb2490e78";
    sha256 = "sha256-LYxkXWJARzpxjGSCRMnL8EBX0Vqh0LJMnURo7ubuou4=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-yearly-review";
    maintainers = with maintainers; [ talyz ];
    license = licenses.mit;
    description = "Publishes an automated Year in Review topic";
  };
}
