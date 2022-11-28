{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-saved-searches";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-saved-searches";
    rev = "e9f9c57297788cc2bb7f3cf3b093fc5a1385cb80";
    sha256 = "sha256-uO6e0zVdeJB3F4n2cv+5EO1O5gHdJATzWsgvPPbCTBc=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-saved-searches";
    maintainers = with maintainers; [ dpausp ];
    license = licenses.mit;
    description = "Allow users to save searches and be notified of new results";
  };
}
