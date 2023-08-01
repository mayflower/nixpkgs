{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-saved-searches";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-saved-searches";
    rev = "334d2be17d512999ae934608989d2daa22f3a751";
    sha256 = "sha256-EHRdtxB0Tu1g9/EWK/ijREagNX+3q5yXpByrx0dc5B8=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-saved-searches";
    maintainers = with maintainers; [ dpausp ];
    license = licenses.mit;
    description = "Allow users to save searches and be notified of new results";
  };
}
