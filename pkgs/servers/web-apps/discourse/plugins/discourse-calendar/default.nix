{
  lib,
  mkDiscoursePlugin,
  fetchFromGitHub,
}:

mkDiscoursePlugin {
  name = "discourse-calendar";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-calendar";
    rev = "fdf3ad927744a9dbb826cc46e489cca8ad469044";
    sha256 = "sha256-3Ie/neUZYBZVE0dpsNn/+7sOT6mqaTTv79g/xMp9N38=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-calendar";
    maintainers = with maintainers; [ ryantm ];
    license = licenses.mit;
    description = "Adds the ability to create a dynamic calendar in the first post of a topic";
  };
}
