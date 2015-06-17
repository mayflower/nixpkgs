{ stdenv, lib, goPackages, fetchFromGitHub }:

with goPackages;

buildGoPackage rec {
  name = "packer-0.8.0-git"; #FIXME
  goPackagePath = "github.com/mitchellh/packer";

  src = fetchFromGitHub {
    owner = "mayflower";
    repo = "packer";
    rev = "c8d66174fe8bdb37395797a48272605ecaa7ae66";
    sha256 = "1k3s69pvar4cl3dnhy099aqdjx7jfqps9kkv748ipl134w795mzg";
  };

  propagatedBuildInputs = [ atlas-go panicwrap yamux cli osext mapstructure iochan go-checkpoint
    prefixedio crypto go-multierror reflectwalk multistep go-fs aws-sdk-go
    winrmtest winrm iso8601 oauth2 gosshold godo tail google-api-go-client
    gcloud-golang-compute-metadata gophercloud toolkit go-vnc
    ugorji.go #FIXME
    ];

  extraSrcs = [
    { inherit (winrmcp) src goPackagePath; }
  ];

  meta = with stdenv.lib; {
    description = "A tool for creating identical machine images for multiple platforms from a single source configuration";
    homepage    = "http://www.packer.io";
    license     = licenses.mpl20;
    maintainers = with maintainers; [ cstrahan ];
    platforms   = platforms.unix;
  };
}
