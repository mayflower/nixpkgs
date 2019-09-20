{ stdenv, substituteAll, buildEnv, fetchFromGitHub, python3Packages }:

stdenv.mkDerivation rec {
  pname = "wee-slack";
  version = "2.3.0";

  src = fetchFromGitHub {
    repo = "wee-slack";
    owner = "wee-slack";
    rev = "v${version}";
    sha256 = "0544j6vqbvb2xshq7ma2a3apx2vvpgfg3jh5prg265wnh4991nsw";
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
