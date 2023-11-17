{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-subscriptions";
  bundlerEnvArgs.gemdir = ./.;
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-subscriptions";
    rev = "3aec1a9336c711a984016e96bb015fd4f9a29c9e";
    sha256 = "sha256-AqqV3RiA9BwjKPQ9UuxuiGNR2jCJLqpTrB0eXTE4Qy0=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-subscriptions";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Allows payments and subscription management via Stripe. ";
  };
}
