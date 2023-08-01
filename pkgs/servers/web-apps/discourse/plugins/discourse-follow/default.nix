{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-follow";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-follow";
    rev = "83d3d61797ba989e5ddea8786235b9ade9ad57af";
    sha256 = "sha256-qlC8HnI3t6c9NAE6TeClheRQ1RK0JRXdYeGb4k1dykE=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-follow";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.gpl2;
    description = "Allows you to follow other users, list the latest topics involving them and receive notifications when they post";
  };
}
