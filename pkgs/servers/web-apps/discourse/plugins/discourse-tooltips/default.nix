{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-tooltips";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-tooltips";
    rev = "34cb12829882f84d1dedaad38df9d52be19b60f3";
    sha256 = "sha256-XDQJsz2+kRxFwhMJshs/Bqey1nsiDoINfN/ePlS2PL8=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-tooltips";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Show tooltips around Discourse on hover, including topic previews";
  };
}
