{ mkYarnPackage, fetchFromGitHub, nodejs, nodePackages, python3, rustPlatform, openssl, pkg-config, protobuf, lib }:
let

  prisma-engines = rustPlatform.buildRustPackage {
    pname = "prisma-engines";
    version = "2.21.1";
    src = fetchFromGitHub {
      owner = "prisma";
      repo = "prisma-engines";
      rev = "2.21.1";
      sha256 = "0xzadc53cml65rr2chncqb1jr0d3rwympc10zw1pci4s1yh2gagi";
    };
    cargoSha256 = sha256:0rm4xi0443071aj737zwh3k3y0iqwhnkjqxzjrvxjb6crc48ayv7;
    OPENSSL_NO_VENDOR = 1;
    PROTOC = "${protobuf}/bin/protoc";
    PROTOC_INCLUDE = "${protobuf}/include";
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ openssl ];
    # Tests require various running database servers
    doCheck = false;
  };

in mkYarnPackage {
  pname = "calendso";
  version = "unstable-2021-04-26";
  src = fetchFromGitHub {
    owner = "calendso";
    repo = "calendso";
    rev = "18d1974ae0aeff5ffd3dfd235fea76da680e0620";
    sha256 = "1gw49iknr5i6lj2bxc42frx52kkwfscbds1wyg04fbc16h8av4qc";
  };
  yarnNix = ./yarn.nix;
  yarnLock = ./yarn.lock;
  packageJSON = ./package.json;

  # This should probably happen in postBuild; however, the next build
  # doesn't work, for reasons which are still somewhat unclear to me
  # but probably related to being in the installation prefix and
  # having performed the fixup.
  postInstall = ''
    cat >> $out/libexec/calendso/prisma.env <<EOF
    PRISMA_MIGRATION_ENGINE_BINARY=${prisma-engines}/bin/migration-engine
    PRISMA_QUERY_ENGINE_BINARY=${prisma-engines}/bin/query-engine
    PRISMA_QUERY_ENGINE_LIBRARY=${prisma-engines}/lib/libquery_engine_napi.so
    PRISMA_INTROSPECTION_ENGINE_BINARY=${prisma-engines}/bin/introspection-engine
    PRISMA_FMT_BINARY=${prisma-engines}/bin/prisma-fmt
    EOF
    export $(<$out/libexec/calendso/prisma.env)

    pushd $out/libexec/calendso/deps/calendso
    ../../node_modules/.bin/next build
    ../../node_modules/.bin/prisma generate
    popd
  '';

  passthru = {
    inherit prisma-engines;
  };
}
