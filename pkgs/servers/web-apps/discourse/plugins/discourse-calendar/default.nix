{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-calendar";
  bundlerEnvArgs.gemdir = ./.;
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-calendar";
    rev = "3b0a8d626dd4233fe52c9686ad5649255ddc3cfb";
    sha256 = "sha256-wwKrgHtUjvPn1iSMkUcldH1aE77twuXUX1wbUyJo+eI=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-calendar";
    maintainers = with maintainers; [ ryantm ];
    license = licenses.mit;
    description = "Adds the ability to create a dynamic calendar in the first post of a topic";
  };
}
