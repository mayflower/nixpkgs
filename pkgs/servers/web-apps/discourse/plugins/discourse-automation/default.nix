{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-automation";
  bundlerEnvArgs.gemdir = ./.;
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-automation";
    rev = "709592ecc12c566ee4221076f200065168e03837";
    sha256 = "sha256-t4C77jIaapSzAexdfNgKLj1uXd1QA9VWH+QRObZrdpU=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-automation";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Lets you automate actions through scripts and triggers";
  };
}
