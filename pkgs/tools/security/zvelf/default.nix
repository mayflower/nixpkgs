{ stdenv, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  name = "zvelf-${version}";
  version = "0.1.0-git";

  # src = fetchFromGitHub {
  #   owner = "mayflower";
  #   repo = "zvelf";
  #   rev = "master";
  #   sha256 = "1ka6ph54gzn0f84aazdkzi7qxnhmbyjys8ja0fcb8y2bl5xjz1r2";
  # };
  src = ../../../../../zvelf;

  depsSha256 = "0l955b0nzmla03m8miqqpbc00viirbsmjjwn3d5p2h3zlp0m1hsl";

  meta = with stdenv.lib; {
    description = "Check ELF files for compiler hardening flags.";
    inherit (src.meta) homepage;
    license = with licenses; [ mit asl20 ];
    maintainers = [ maintainers.globin ];
    platforms = platforms.all;
  };
}
