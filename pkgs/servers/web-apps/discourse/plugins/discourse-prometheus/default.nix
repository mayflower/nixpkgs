{ lib, stdenv, mkDiscoursePlugin, fetchFromGitHub }:

 mkDiscoursePlugin {
  bundlerEnvArgs.gemdir = ./.;
  name = "discourse-prometheus";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-prometheus";
    rev = "639b8936ca20758802284a35e2b5e764e0a032f9";
    sha256 = "sha256-E9t2bEdv+/zhof6vXMr6Z4JHd0rS8VhQfaCJOLCOStI=";
  };

  patches = [
    # The metrics collector tries to run git to get the commit id but fails
    # because we don't run Discourse from a Git repository.
    ./no-git-version.patch
  ];

  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-prometheus";
    maintainers = with maintainers; [ dpausp ];
    license = licenses.mit;
    description = "Official Discourse Plugin for Prometheus Monitoring";
  };
}
