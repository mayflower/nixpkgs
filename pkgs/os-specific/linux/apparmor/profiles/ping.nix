{ stdenv, pkgs, storeDir, iputils, nettle, libcap, libcap_ng, libidn }:

pkgs.writeText "apparmor-extra-profiles-ping" ''
#include <tunables/global>

/run/wrappers/wrappers.*/ping {
  #include <abstractions/base>

  capability net_raw,

  /etc/resolv.conf r,
  ${stdenv.cc.libc_lib}/lib/ld-*.so mr,
  ${stdenv.cc.libc_lib}/lib/lib*so* mr,
  ${stdenv.cc.libc_lib}/share/locale/locale.alias r,
  ${storeDir}/*-etc-hosts r, #*/
  ${libcap.lib}/lib/libcap.so* mr,
  ${libcap_ng}/lib/libcap-ng.so* mr,
  ${libidn.out}/lib/libidn.so.* mr,
  ${storeDir}/*-glibc-locales-*/lib/locale/locale-archive r,
  ${storeDir}/*-etc-host.conf r, #*/
  ${iputils}/bin/ping Cx,
  ${iputils}/bin/ping mr,
  ${nettle}/lib/libnettle.so.* mr,
  ${storeDir}/*-etc-nsswitch.conf r, #*/
  /proc/*/status r, #*/
  /run/wrappers/wrappers.*/ping mr,
  /run/wrappers/wrappers.*/ping.real r,


  profile ${iputils}/bin/ping {
    #include <abstractions/base>

    capability net_raw,

    /etc/resolv.conf r,
    ${stdenv.cc.libc_lib}/lib/ld-*.so mr,
    ${stdenv.cc.libc_lib}/lib/libc-*.so mr,
    ${stdenv.cc.libc_lib}/lib/libm-*.so mr,
    ${stdenv.cc.libc_lib}/lib/libnss_dns-*.so mr,
    ${stdenv.cc.libc_lib}/lib/libnss_files-*.so mr,
    ${stdenv.cc.libc_lib}/lib/libresolv-*.so mr,
    ${storeDir}/*-etc-hosts r, #*/
    ${libcap.lib}/lib/libcap.so.* mr,
    ${libidn.out}/lib/libidn.so.* mr,
    ${storeDir}/*-glibc-locales-*/lib/locale/locale-archive r,
    ${storeDir}/*-etc-host.conf r, #*/
    ${iputils}/bin/ping mr,
    ${nettle}/lib/libnettle.so.* mr,
    ${storeDir}/*-etc-nsswitch.conf r, #*/

  }

}
''
