{ callPackage, python }:

{
  weechat-xmpp = callPackage ./weechat-xmpp { };
  weechat-matrix = callPackage ./weechat-matrix-bridge { };
  wee-slack = callPackage ./wee-slack { };
  weechat-autosort = callPackage ./weechat-autosort { };
}
