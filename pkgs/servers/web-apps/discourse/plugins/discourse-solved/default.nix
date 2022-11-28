{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-solved";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-solved";
    rev = "0dd0d0b9a63993399e94e640645ca71f59779999";
    sha256 = "sha256-bC0Q6HWQ6MB1Ma+tF1fmgeW6fVAX9coqcQsbLYpnP5o=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-solved";
    maintainers = with maintainers; [ talyz ];
    license = licenses.mit;
    description = "Allow accepted answers on topics";
  };
}
