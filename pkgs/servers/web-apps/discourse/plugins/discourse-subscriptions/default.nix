{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-subscriptions";
  bundlerEnvArgs.gemdir = ./.;
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-subscriptions";
    rev = "425fbc0af190fdf26fde66eec5e529ce24ad1955";
    sha256 = "sha256-I+MI9cXuL78DsG+CJ0Lu46lZMHMW1h2dQB4ljNkPqCc=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-subscriptions";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Allows payments and subscription management via Stripe. ";
  };
}
