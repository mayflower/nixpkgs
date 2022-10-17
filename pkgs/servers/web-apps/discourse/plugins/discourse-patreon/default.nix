{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-patreon";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-patreon";
    rev = "0c88b9bf3b588053836b32f6bf551ea06f0b6963";
    sha256 = "sha256-7jj+Posb3W+XG5AE5u0jadhk/z2mjC44efzzl4xl4Cc=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-patreon";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Enable syncronization between Discourse Groups and Patreon rewards, and enable Patreon Social Login";
  };
}
