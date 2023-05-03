{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-automation";
  bundlerEnvArgs.gemdir = ./.;
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-automation";
    rev = "9d95ba9bc20086566c65909b563c65a9a32ec35f";
    sha256 = "sha256-UBLewqSSP4fK6WG0Z2gEeq9Gt6OnosCrPurL0yhPeJo=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-automation";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Lets you automate actions through scripts and triggers";
  };
}
