{ lib, fetchFromGitHub }:
rec {
  version = "8.1.1967";

  src = fetchFromGitHub {
    owner = "vim";
    repo = "vim";
    rev = "v${version}";
    sha256 = "0cdfi67jwv8j982i1jxdfqv4aqglig8f0hzadgygk69i0wwkymwk";
  };

  enableParallelBuilding = true;

  hardeningDisable = [ "fortify" ];

  patches = [
    # Arbitrary code execution fix
    # https://github.com/numirias/security/blob/cf4f74e0c6c6e4bbd6b59823aa1b85fa913e26eb/doc/2019-06-04_ace-vim-neovim.md
    ./0001-source-command-doesnt-check-for-the-sandbox-5357552.patch
  ];

  postPatch =
    # Use man from $PATH; escape sequences are still problematic.
    ''
      substituteInPlace runtime/ftplugin/man.vim \
        --replace "/usr/bin/man " "man "
    '';

  meta = with lib; {
    description = "The most popular clone of the VI editor";
    homepage    = http://www.vim.org;
    license     = licenses.vim;
    maintainers = with maintainers; [ lovek323 ];
    platforms   = platforms.unix;
  };
}
