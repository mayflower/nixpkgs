{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-subscriptions";
  bundlerEnvArgs.gemdir = ./.;
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-subscriptions";
    rev = "bb96d77056a9ef842e01e46fd980320d427073ad";
    sha256 = "sha256-D+bE1N2wX/LdFjPJkTn4t4vn5u0P0PQBeEH9bJp2cF8=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-subscriptions";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Allows payments and subscription management via Stripe. ";
  };
}
