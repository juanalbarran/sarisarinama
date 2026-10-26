# modules/ui/keybinds/presets/yazi.nix
# yazi: its defaults, picked from the manager keymap of yazi 26.5.6
# (yazi-config/preset/keymap-default.toml). s needs fd, z fzf and Z zoxide
# on PATH. A config that rebinds keys adds its own group with lib.mkAfter,
# or replaces these with lib.mkForce.
{
  flake.modules.homeManager.sarisarinama.programs.sarisarinama.keybinds.yazi = {
    label = "Yazi";
    icon = "󰇥 ";
    order = 25;
    groups = [
      {
        title = "Move";
        binds = [
          {
            keys = "j";
            description = "Next file";
          }
          {
            keys = "k";
            description = "Previous file";
          }
          {
            keys = "h";
            description = "Parent directory";
          }
          {
            keys = "l";
            description = "Enter the directory";
          }
          {
            keys = "g g";
            description = "Top";
          }
          {
            keys = "G";
            description = "Bottom";
          }
          {
            keys = "Ctrl+d";
            description = "Down half a page";
          }
          {
            keys = "Ctrl+u";
            description = "Up half a page";
          }
          {
            keys = "H";
            description = "Back in history";
          }
          {
            keys = "L";
            description = "Forward in history";
          }
          {
            keys = "J";
            description = "Scroll the preview down";
          }
          {
            keys = "K";
            description = "Scroll the preview up";
          }
        ];
      }
      {
        title = "Go to";
        binds = [
          {
            keys = "g h";
            description = "Home";
          }
          {
            keys = "g c";
            description = "~/.config";
          }
          {
            keys = "g d";
            description = "~/Downloads";
          }
          {
            keys = "g Space";
            description = "Type a directory";
          }
          {
            keys = "g f";
            description = "Follow the symlink";
          }
        ];
      }
      {
        title = "Select";
        binds = [
          {
            keys = "Space";
            description = "Select the file";
          }
          {
            keys = "Ctrl+a";
            description = "Select every file";
          }
          {
            keys = "Ctrl+r";
            description = "Invert the selection";
          }
          {
            keys = "v";
            description = "Visual mode";
          }
          {
            keys = "Esc";
            description = "Clear the selection";
          }
        ];
      }
      {
        title = "Files";
        binds = [
          {
            keys = "Enter";
            description = "Open";
          }
          {
            keys = "O";
            description = "Open with";
          }
          {
            keys = "y";
            description = "Copy";
          }
          {
            keys = "x";
            description = "Cut";
          }
          {
            keys = "p";
            description = "Paste";
          }
          {
            keys = "P";
            description = "Paste, overwriting";
          }
          {
            keys = "Y";
            description = "Cancel the copy or cut";
          }
          {
            keys = "d";
            description = "Move to the trash";
          }
          {
            keys = "D";
            description = "Delete for good";
          }
          {
            keys = "a";
            description = "Create; end with / for a directory";
          }
          {
            keys = "r";
            description = "Rename";
          }
          {
            keys = ".";
            description = "Show hidden files";
          }
        ];
      }
      {
        title = "Find";
        binds = [
          {
            keys = "f";
            description = "Filter the directory";
          }
          {
            keys = "/";
            description = "Find down";
          }
          {
            keys = "?";
            description = "Find up";
          }
          {
            keys = "n";
            description = "Next match";
          }
          {
            keys = "N";
            description = "Previous match";
          }
          {
            keys = "s";
            description = "Search names (fd)";
          }
          {
            keys = "S";
            description = "Search contents (ripgrep)";
          }
          {
            keys = "z";
            description = "Jump with fzf";
          }
          {
            keys = "Z";
            description = "Jump with zoxide";
          }
        ];
      }
      {
        title = "Copy paths";
        binds = [
          {
            keys = "c c";
            description = "Copy the path";
          }
          {
            keys = "c d";
            description = "Copy the directory";
          }
          {
            keys = "c f";
            description = "Copy the file name";
          }
          {
            keys = "c n";
            description = "Copy the name, no extension";
          }
        ];
      }
      {
        title = "Tabs";
        binds = [
          {
            keys = "t t";
            description = "New tab";
          }
          {
            keys = "1…9";
            description = "Tab by number";
          }
          {
            keys = "[";
            description = "Previous tab";
          }
          {
            keys = "]";
            description = "Next tab";
          }
          {
            keys = "Ctrl+c";
            description = "Close the tab";
          }
        ];
      }
      {
        title = "Other";
        binds = [
          {
            keys = ",";
            description = "Sort, then a key";
          }
          {
            keys = "m";
            description = "Line mode, then a key";
          }
          {
            keys = ";";
            description = "Run a shell command";
          }
          {
            keys = ":";
            description = "Run a shell command and wait";
          }
          {
            keys = "w";
            description = "Tasks";
          }
          {
            keys = "~";
            description = "List every key";
          }
          {
            keys = "q";
            description = "Quit";
          }
        ];
      }
    ];
  };
}
