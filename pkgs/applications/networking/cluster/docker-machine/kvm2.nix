{ stdenv, buildGoPackage, minikube, libvirt, pkgconfig }:

buildGoPackage rec {
  name = "docker-machine-kvm2-${version}";
  version = minikube.version;

  inherit (minikube) src;

  goPackagePath = "k8s.io/minikube";
  subPackages = [ "cmd/drivers/kvm" ];

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ libvirt ];

  postInstall = "mv $bin/bin/kvm $bin/bin/docker-machine-driver-kvm2";

  meta = with stdenv.lib; {
    description = "KVM driver for docker-machine.";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
