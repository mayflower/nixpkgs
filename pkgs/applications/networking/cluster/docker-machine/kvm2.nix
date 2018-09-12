{ stdenv, buildGoPackage, minikube, libvirt, pkgconfig }:

buildGoPackage rec {
  name = "docker-machine-kvm2-${version}";
  version = minikube.version;

  inherit (minikube) src;

  goPackagePath = "k8s.io/minikube";
  subPackages = [ "cmd/drivers/kvm" ];

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ libvirt ];

  preBuild = ''
    export buildFlagsArray=(-ldflags="-X k8s.io/minikube/pkg/drivers/kvm/version.VERSION=v${version}")
  '';

  postInstall = ''
    mv $bin/bin/kvm $bin/bin/docker-machine-driver-kvm2
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/kubernetes/minikube/blob/master/docs/drivers.md;
    description = "KVM2 driver for docker-machine.";
    license = licenses.asl20;
    maintainers = with maintainers; [ tadfisher ];
    platforms = platforms.unix;
  };
}
