{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-subscriptions";
  bundlerEnvArgs.gemdir = ./.;
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-subscriptions";
    rev = "aba86e5e255a0c0046a172b7d1d6e1af91ed022f";
    sha256 = "sha256-VY0MRYIeV+ty2j2GACHzTctP6V/1hnmF24SPWZe3J7A=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-subscriptions";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Allows payments and subscription management via Stripe. ";
  };
}
