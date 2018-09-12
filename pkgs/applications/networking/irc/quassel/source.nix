{ fetchurl, fetchpatch }:

rec {
  version = "0.12.5";
  src = fetchurl {
    url = "https://github.com/quassel/quassel/archive/${version}.tar.gz";
    sha256 = "04f42x87a4wkj3va3wnmj2jl7ikqqa7d7nmypqpqwalzpzk7kxwv";
  };
  patches = [
    (fetchpatch {
      name = "CVE-XXX-RCE.patch";
      url = "https://quassel-irc.org/pub/misc/0001-Implement-custom-deserializer-to-add-our-own-sanity-.patch";
      sha256 = "0w7gx0xhqfb2h1rxlh9q96bdd23szbxdjs3ydmrzzvyxj5sk8dzd";
    })
    (fetchpatch {
      name = "CVE-XXX-DOS.patch";
      url = "https://quassel-irc.org/pub/misc/0002-Reject-clients-that-attempt-to-login-before-the-core.patch";
      sha256 = "0is2jf7qppsx2y10f0zazm27lnkam83wpm8wmnfmdxdxj656ifd1";
    })
  ];
}
