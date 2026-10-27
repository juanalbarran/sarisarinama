# modules/ui/keybinds/presets/foot.nix
# foot: its defaults, from the key-bindings, search-bindings and
# url-bindings sections of the foot.ini that foot 1.27.0 ships. A config
# that rebinds keys adds its own group with lib.mkAfter, or replaces these
# with lib.mkForce.
{
  flake.modules.homeManager.sarisarinama.programs.sarisarinama.keybinds.foot = {
    label = "Foot";
    icon = "󰆍 ";
    order = 26;
    groups = [
      {
        title = "Clipboard";
        binds = [
          {
            keys = "Ctrl+Shift+c";
            description = "Copy";
          }
          {
            keys = "Ctrl+Shift+v";
            description = "Paste";
          }
          {
            keys = "Shift+Ins";
            description = "Paste the selection";
          }
        ];
      }
      {
        title = "Scrollback";
        binds = [
          {
            keys = "Shift+PgUp";
            description = "Up a page";
          }
          {
            keys = "Shift+PgDn";
            description = "Down a page";
          }
          {
            keys = "Ctrl+Shift+z";
            description = "Previous prompt";
          }
          {
            keys = "Ctrl+Shift+x";
            description = "Next prompt";
          }
        ];
      }
      {
        title = "Search";
        binds = [
          {
            keys = "Ctrl+Shift+r";
            description = "Search the scrollback";
          }
          {
            keys = "Ctrl+r";
            description = "Previous match";
          }
          {
            keys = "Ctrl+s";
            description = "Next match";
          }
          {
            keys = "Ctrl+w";
            description = "Extend the match to a word";
          }
          {
            keys = "Enter";
            description = "Select the match";
          }
          {
            keys = "Esc";
            description = "Cancel";
          }
        ];
      }
      {
        title = "URLs";
        binds = [
          {
            keys = "Ctrl+Shift+o";
            description = "Open a URL";
          }
          {
            keys = "{hint}";
            description = "Pick the URL by its letters";
          }
          {
            keys = "t";
            description = "Show the URLs in full";
          }
          {
            keys = "Esc";
            description = "Cancel";
          }
        ];
      }
      {
        title = "Font";
        binds = [
          {
            keys = "Ctrl+Plus";
            description = "Bigger";
          }
          {
            keys = "Ctrl+-";
            description = "Smaller";
          }
          {
            keys = "Ctrl+0";
            description = "Default size";
          }
        ];
      }
      {
        title = "Other";
        binds = [
          {
            keys = "Ctrl+Shift+n";
            description = "New window";
          }
          {
            keys = "Ctrl+Shift+u";
            description = "Type a Unicode character";
          }
        ];
      }
    ];
  };
}
