# Create an initramfs containing the closure of the specified
# file system objects.  An initramfs is used during the initial
# stages of booting a Linux system.  It is loaded by the boot loader
# along with the kernel image.  It's supposed to contain everything
# (such as kernel modules) necessary to allow us to mount the root
# file system.  Once the root file system is mounted, the `real' boot
# script can be called.
#
# An initramfs is a cpio archive, and may be compressed with a number
# of algorithms.
let
  # Some metadata on various compression programs, relevant to naming
  # the initramfs file and, if applicable, generating a u-boot image
  # from it.
  compressors = rec {
    cat = {
      ubootName = "none";
      extension = ".cpio";
    };
    gzip = {
      ubootName = "gzip";
      extension = ".gz";
    };
    pigz = gzip;
    lzma = {
      ubootName = "lzma";
      extension = ".lzma";
    };
  };
  # Get the basename of the actual compression program from the whole
  # compression command, for the purpose of guessing the u-boot
  # compression type and filename extension.
  compressorName = fullCommand: builtins.elemAt (builtins.match "([^ ]*/)?([^ ]+).*" fullCommand) 1;
in
{ stdenvNoCC, perl, cpio, ubootTools, lib
# Name of the derivation (not of the resulting file!)
, name ? "initrd"

# Program used to compress the cpio archive; use "cat" for no compression.
, compressor ? "gzip -9n"

# Filename extension to use for the compressed initramfs. This is
# included for clarity, but $out/initrd will always be a symlink to
# the final image.
# If this isn't guessed, you may want to complete the metadata above and send a PR :)
, extension ?
  # Can't use `or` operator since it doesn't work with dynamic attribute getter
  if lib.hasAttrByPath [ "${compressorName compressor}" "extension" ] compressors
  then compressors."${compressorName compressor}".extension
  else throw "Unrecognised compressor ${compressorName compressor}, please specify extension"

# List of { object = path_or_derivation; symlink = "/path"; }
# The paths are copied into the initramfs in their nix store path
# form, then linked at the root according to `symlink`.
, contents

# List of uncompressed cpio files to prepend to the initramfs. This
# can be used to add files in specified paths without them becoming
# symlinks to store paths.
, prepend ? []

# Whether to wrap the initramfs in a u-boot image.
, makeUInitrd ? stdenvNoCC.hostPlatform.platform.kernelTarget == "uImage"

# If generating a u-boot image, the architecture to use. The default
# guess may not align with u-boot's nomenclature correctly, so it can
# be overridden.
, uInitrdArch ? stdenvNoCC.hostPlatform.parsed.cpu.family

# The name of the compression, as recognised by u-boot.
# See https://gitlab.denx.de/u-boot/u-boot/-/blob/9bfb567e5f1bfe7de8eb41f8c6d00f49d2b9a426/common/image.c#L195-204 for a list.
# If this isn't guessed, you may want to complete the metadata above and send a PR :)
, uInitrdCompression ?
  if lib.hasAttrByPath [ "${compressorName compressor}" "ubootName" ] compressors
  then compressors."${compressorName compressor}".ubootName
  else throw "Unrecognised compressor ${compressorName compressor}, please specify uInitrdCompression"
}:
let
  # !!! Move this into a public lib function, it is probably useful for others
  toValidStoreName = x: with builtins;
    lib.concatStringsSep "-" (filter (x: !(isList x)) (split "[^a-zA-Z0-9_=.?-]+" x));

in stdenvNoCC.mkDerivation rec {
  inherit name makeUInitrd extension uInitrdArch uInitrdCompression;

  builder = ./make-initrd.sh;

  nativeBuildInputs = [ perl cpio ]
    ++ stdenvNoCC.lib.optional makeUInitrd ubootTools;

  # !!! should use XML.
  objects = map (x: x.object) contents;
  symlinks = map (x: x.symlink) contents;
  suffices = map (x: if x ? suffix then x.suffix else "none") contents;

  # For obtaining the closure of `contents'.
  # Note: we don't use closureInfo yet, as that won't build with nix-1.x.
  # See #36268.
  exportReferencesGraph =
    lib.zipListsWith
      (x: i: [("closure-${toValidStoreName (baseNameOf x.symlink)}-${toString i}") x.object])
      contents
      (lib.range 0 (lib.length contents - 1));
  pathsFromGraph = ./paths-from-graph.pl;

  inherit compressor prepend;
}
