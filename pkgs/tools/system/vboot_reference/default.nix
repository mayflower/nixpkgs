{ lib, stdenv, fetchFromGitiles, fetchFromGitHub, pkg-config, libuuid, openssl, libyaml, xz }:
let
  shflags = fetchFromGitHub {
    owner = "kward";
    repo = "shflags";
    rev = "7d0daf1b3b3163c34e0108cdb439e2cd2f148152";
    sha256 = "1fjmj437hin4vh7pa36n4vrd9j428qmbq99mmsv4zdb7v8591vmp";
  };

in stdenv.mkDerivation rec {
  version = "20180311";
  checkout = "4c84e077858c809ee80a9a6f9b38185cf7dcded7";

  pname = "vboot_reference";

  src = fetchFromGitiles {
    url = "https://chromium.googlesource.com/chromiumos/platform/vboot_reference";
    rev = checkout;
    sha256 = "1zja4ma6flch08h5j2l1hqnxmw2xwylidnddxxd5y2x05dai9ddj";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl libuuid libyaml xz ];

  enableParallelBuilding = true;

  patches = [ ./dont_static_link.patch ];

  # fix build with gcc9
  NIX_CFLAGS_COMPILE = [ "-Wno-error" ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace "ar qc" '${stdenv.cc.bintools.targetPrefix}ar qc'
    substituteInPlace scripts/image_signing/common_minimal.sh \
      --replace "/usr/share/misc/shflags" "${shflags}/shflags"
  '';

  preBuild = ''
    patchShebangs scripts
  '';

  makeFlags = [
    "DESTDIR=$(out)"
    "HOST_ARCH=${stdenv.hostPlatform.parsed.cpu.name}"
  ];

  postInstall = ''
    mkdir -p $out/share/vboot
    cp -r tests/devkeys* $out/share/vboot/
  '';

  meta = with lib; {
    description = "Chrome OS partitioning and kernel signing tools";
    license = licenses.bsd3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ lheckemann ];
  };
}
