# modules/ui/theme/options.nix
# programs.sarisarinama.theme: the palettes, and which one the shell starts
# with. A palette holds the keys of an omarchy themes/<name>/colors.toml;
# _lib/palette.nix completes it, so a theme may declare as little as it likes.
# Surface tokens (which palette key paints what) live in surfaces.nix.
{
  flake.modules.homeManager.sarisarinama = {lib, ...}: {
    options.programs.sarisarinama.theme = {
      default = lib.mkOption {
        type = lib.types.str;
        default = "tokyo-night";
        description = ''
          Theme the shell falls back to when nothing was picked at runtime.
          Must name an entry of `palettes`.
        '';
      };

      palettes = lib.mkOption {
        type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
        default = {};
        example = lib.literalExpression ''{ my-theme = { background = "#101010"; foreground = "#e0e0e0"; }; }'';
        description = ''
          One entry per theme, rendered to themes/<name>.json. Keys are the
          semantic names of an omarchy colors.toml; color0..color15 are
          accepted too. Missing keys are derived, not defaulted to a
          foreign colour.
        '';
      };
    };
  };
}
