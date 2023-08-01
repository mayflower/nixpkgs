{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-subscriptions";
  bundlerEnvArgs.gemdir = ./.;
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-subscriptions";
    rev = "7140517ec87c8b7cc91770da93e09d853447b6b3";
    sha256 = "sha256-+W3XCtkqsJ5GBauOybFj3uLrPHVHJbtv7fKn6dKbZHU=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-subscriptions";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Allows payments and subscription management via Stripe. ";
  };
}
