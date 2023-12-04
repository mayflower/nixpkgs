{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-solved";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-solved";
    rev = "9fbf43e2f077e86f0a1ff769af6036d4e78bfff1";
    sha256 = "sha256-RiGeEOA4wwR3d/w/QerRW1dDwEYD63sAxf7dkX5Zlr0=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-solved";
    maintainers = with maintainers; [ talyz ];
    license = licenses.mit;
    description = "Allow accepted answers on topics";
  };
}
