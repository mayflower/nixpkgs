{ stdenv, fetchFromGitLab, git, go }:

stdenv.mkDerivation rec {
  name = "gitlab-workhorse-${version}";

  version = "8.0.0";

  src = fetchFromGitLab {
    owner = "gitlab-org";
    repo = "gitlab-workhorse";
    rev = "v${version}";
    sha256 = "09r2426ybib9r0166j0y7ks0i5iqdpl2cg1fdiw10fjh27vsdkvr";
  };

  buildInputs = [ git go ];

  makeFlags = [ "PREFIX=$(out)" "VERSION=${version}" ];

  meta = with stdenv.lib; {
    homepage = http://www.gitlab.com/;
    platforms = platforms.unix;
    maintainers = with maintainers; [ fpletz globin ];
    license = licenses.mit;
  };
}
