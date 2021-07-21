{ lib, fetchpatch, fetchFromGitHub, yarn2nix-moretea, nodejs }:
yarn2nix-moretea.mkYarnPackage rec {
  version = "0.8.83";

  src = fetchFromGitHub {
    owner = "Ylianst";
    repo = "MeshCentral";
    rev = "56dae7fac5b44db521e812e41a9b5fef78d542fd";
    sha256 = "1a0y1zmzv2cwrav34hzsm8bwkjh4q4dkqff5in6l220mx23y1zdp";
  };

  patches = [
    # Don't interpret --configfile as relative to --datadir
    (fetchpatch {
      url = "https://github.com/Ylianst/MeshCentral/commit/dec1f3c4892c730e9f840c35bfc3504738ef2ada.patch";
      sha256 = "02lzlihicrhrpkk2p7fzrvm47nfvwrabxb368ssqvxx9wh981r8f";
    })
  ];

  packageJSON = ./package.json;
  yarnLock = ./yarn.lock;
  yarnNix = ./yarn.nix;

  preFixup = ''
    mkdir -p $out/bin
    chmod a+x $out/libexec/meshcentral/deps/meshcentral/meshcentral.js
    sed -i '1i#!${nodejs}/bin/node' $out/libexec/meshcentral/deps/meshcentral/meshcentral.js
    ln -s $out/libexec/meshcentral/deps/meshcentral/meshcentral.js $out/bin/meshcentral
  '';

  publishBinsFor = [ ];

  postInstall = ''
    ln -snf $out/libexec/meshcentral/node_modules $out/libexec/meshcentral/deps/meshcentral/node_modules
  '';

  meta = with lib; {
    description = "Computer management web app";
    homepage = "https://meshcentral.com/info/";
    maintainer = [ maintainers.lheckemann ];
    license = licenses.asl20;
  };
}
