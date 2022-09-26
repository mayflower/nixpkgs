{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-zendesk-plugin";
  bundlerEnvArgs.gemdir = ./.;
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-zendesk-plugin";
    rev = "4ea4d3179c05e14a70be0bd77caf4bcaf0ef07a5";
    sha256 = "sha256-rUkwc9D/YZYqkhoyjwAvktNBFzl1/tLvvaEgCiYhbqc=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-zendesk-plugin";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Official Zendesk Integration for Discourse";
  };
}
