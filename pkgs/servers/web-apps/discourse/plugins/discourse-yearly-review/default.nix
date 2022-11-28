{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-yearly-review";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-yearly-review";
    rev = "0af6331f77282ad2c95121f59f01f9bcd0a2ba4e";
    sha256 = "sha256-iM8tnZvij3ChcHjdNpQS86c7CAm7c531BlZ5zae82PU=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-yearly-review";
    maintainers = with maintainers; [ talyz ];
    license = licenses.mit;
    description = "Publishes an automated Year in Review topic";
  };
}
