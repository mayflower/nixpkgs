{ callPackage }:

{
  weechat-matrix = callPackage ./weechat-matrix-bridge { };
  weechat-autosort = callPackage ./weechat-autosort { };
  wee-slack = callPackage ./wee-slack { };

  weechat-otr = callPackage ./weechat-otr { };
}
