# modules/ui/theme/_lib/mix.nix
# Hex arithmetic for the palette cascade, ported from mix_color in omarchy's
# bin/omarchy-theme-color. `amount` is a fraction: 0.25 moves a quarter of the
# way from a to b. Under _lib/, so import-tree does not read it as a module.
lib: rec {
  # "#7aa2f7" -> [122 162 247]
  toRgb = hex: let
    h = lib.removePrefix "#" hex;
    at = i: lib.fromHexString (builtins.substring i 2 h);
  in [(at 0) (at 2) (at 4)];

  # 122 -> "7a"; toHexString yields "7A" and drops the leading zero.
  byte = n: lib.toLower (lib.fixedWidthString 2 "0" (lib.toHexString n));

  toHex = rgb: "#" + lib.concatMapStrings byte rgb;

  mix = a: b: amount: let
    blend = x: y: builtins.floor (x * (1.0 - amount) + y * amount + 0.5);
  in
    toHex (lib.zipListsWith blend (toRgb a) (toRgb b));

  # omarchy's mode test: the raw channel sum, not a perceptual weight.
  isLight = hex: lib.foldl' builtins.add 0 (toRgb hex) > 382;
}
