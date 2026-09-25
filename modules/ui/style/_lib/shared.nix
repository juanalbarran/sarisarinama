# modules/ui/style/_lib/shared.nix
# The shared options every component may override. Each defaults to null,
# which means "take programs.sarisarinama.style.<the same key>". Under
# _lib/, so import-tree does not read it as a module.
lib: component: {
  font = {
    family = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Font family for the ${component}; null takes style.font.family.";
    };
    size = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.unsigned;
      default = null;
      description = ''
        Base font size for the ${component} in px, and the root of its own
        type scale; null takes style.font.size.
      '';
    };
  };

  # Flat, not nested under `spacing`: style.bar.spacing is already the gap
  # between widgets, and a component's own keys win the merge.
  scale = lib.mkOption {
    type = lib.types.nullOr lib.types.numbers.positive;
    default = null;
    description = "Length multiplier for the ${component}; null takes style.spacing.scale.";
  };
}
