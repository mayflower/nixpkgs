{
  lib,
  mkDiscoursePlugin,
  fetchFromGitHub,
}:

mkDiscoursePlugin rec {
  name = "discourse-oauth2-basic";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = name;
    rev = "f0261c88bc5a26aa142ec4b0af9ce3a21cfb3dc8";
    sha256 = "sha256-cABtpUsDTvN2mC3cpYouT1j97SCfKHsIGQgGRspX3fU=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/${name}";
    maintainers = with maintainers; [ ehmry ];
    license = licenses.mit;
    description = "Basic OAuth2 plugin for use with Discourse";
  };
}
