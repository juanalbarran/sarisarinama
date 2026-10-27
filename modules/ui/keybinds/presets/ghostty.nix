# modules/ui/keybinds/presets/ghostty.nix
# ghostty: its defaults on Linux, from `ghostty +list-keybinds --default`
# of ghostty 1.3.1. A config that rebinds keys adds its own group with
# lib.mkAfter, or replaces these with lib.mkForce.
{
  flake.modules.homeManager.sarisarinama.programs.sarisarinama.keybinds.ghostty = {
    label = "Ghostty";
    icon = "󰊠 ";
    order = 27;
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
          {
            keys = "Ctrl+Shift+a";
            description = "Select all";
          }
          {
            keys = "Shift+←↓↑→";
            description = "Extend the selection";
          }
          {
            keys = "Ctrl+Shift+j";
            description = "Save the screen, paste its path";
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
            keys = "Shift+Home";
            description = "Top";
          }
          {
            keys = "Shift+End";
            description = "Bottom";
          }
          {
            keys = "Ctrl+Shift+PgUp";
            description = "Previous prompt";
          }
          {
            keys = "Ctrl+Shift+PgDn";
            description = "Next prompt";
          }
          {
            keys = "Ctrl+Shift+f";
            description = "Search";
          }
          {
            keys = "Esc";
            description = "End the search";
          }
        ];
      }
      {
        title = "Tabs";
        binds = [
          {
            keys = "Ctrl+Shift+t";
            description = "New tab";
          }
          {
            keys = "Ctrl+Shift+w";
            description = "Close the tab";
          }
          {
            keys = "Ctrl+Tab";
            description = "Next tab";
          }
          {
            keys = "Ctrl+Shift+Tab";
            description = "Previous tab";
          }
          {
            keys = "Alt+1…8";
            description = "Tab by number";
          }
          {
            keys = "Alt+9";
            description = "Last tab";
          }
        ];
      }
      {
        title = "Splits";
        binds = [
          {
            keys = "Ctrl+Shift+o";
            description = "Split right";
          }
          {
            keys = "Ctrl+Shift+e";
            description = "Split down";
          }
          {
            keys = "Ctrl+Alt+←↓↑→";
            description = "Split that way";
          }
          {
            keys = "Super+Ctrl+[";
            description = "Previous split";
          }
          {
            keys = "Super+Ctrl+]";
            description = "Next split";
          }
          {
            keys = "Super+Ctrl+Shift+←↓↑→";
            description = "Resize the split";
          }
          {
            keys = "Ctrl+Shift+Enter";
            description = "Zoom the split";
          }
        ];
      }
      {
        title = "Windows";
        binds = [
          {
            keys = "Ctrl+Shift+n";
            description = "New window";
          }
          {
            keys = "Ctrl+Enter";
            description = "Fullscreen";
          }
          {
            keys = "Alt+F4";
            description = "Close the window";
          }
          {
            keys = "Ctrl+Shift+q";
            description = "Quit";
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
            keys = "Ctrl+Shift+p";
            description = "Command palette";
          }
          {
            keys = "Ctrl+,";
            description = "Open the config";
          }
          {
            keys = "Ctrl+Shift+,";
            description = "Reload the config";
          }
          {
            keys = "Ctrl+Shift+i";
            description = "Inspector";
          }
        ];
      }
    ];
  };
}
