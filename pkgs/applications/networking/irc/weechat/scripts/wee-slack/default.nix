{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "wee-slack-${version}";
  version = "2.2.0";

  src = fetchFromGitHub {
    repo = "wee-slack";
    owner = "wee-slack";
    rev = "v${version}";
    sha256 = "1iy70q630cgs7fvk2151fq9519dwxrlqq862sbrwypzr6na6yqpg";
  };

  passthru = {
    scripts = [ "wee_slack.py" ];
    withPyPackages = ps: with ps; [ websocket_client six ];
  };

  installPhase = ''
    mkdir -p $out/share
    cp wee_slack.py $out/share/wee_slack.py
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/wee-slack/wee-slack;
    license = licenses.mit;
    maintainers = with maintainers; [ ma27 ];
    description = ''
      A WeeChat plugin for Slack.com. Synchronizes read markers, provides typing notification, search, etc..
    '';
  };
}
