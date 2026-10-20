# modules/ui/keybinds/presets/tmux.nix
# tmux: the defaults with the Ctrl+b prefix and vi copy mode, picked from
# `tmux list-keys -N`. A config that rebinds keys adds its own group with
# lib.mkAfter, or replaces these with lib.mkForce.
{
  flake.modules.homeManager.sarisarinama.programs.sarisarinama.keybinds.tmux = {
    label = "Tmux";
    icon = " ";
    order = 20;
    groups = [
      {
        title = "Sessions";
        binds = [
          {
            keys = "Ctrl+b d";
            description = "Detach";
          }
          {
            keys = "Ctrl+b s";
            description = "Choose a session";
          }
          {
            keys = "Ctrl+b $";
            description = "Rename the session";
          }
          {
            keys = "Ctrl+b (";
            description = "Previous session";
          }
          {
            keys = "Ctrl+b )";
            description = "Next session";
          }
        ];
      }
      {
        title = "Windows";
        binds = [
          {
            keys = "Ctrl+b c";
            description = "New window";
          }
          {
            keys = "Ctrl+b ,";
            description = "Rename the window";
          }
          {
            keys = "Ctrl+b n";
            description = "Next window";
          }
          {
            keys = "Ctrl+b p";
            description = "Previous window";
          }
          {
            keys = "Ctrl+b 0…9";
            description = "Window by number";
          }
          {
            keys = "Ctrl+b w";
            description = "Choose a window";
          }
          {
            keys = "Ctrl+b &";
            description = "Kill the window";
          }
        ];
      }
      {
        title = "Panes";
        binds = [
          {
            keys = "Ctrl+b %";
            description = "Split left and right";
          }
          {
            keys = "Ctrl+b \"";
            description = "Split top and bottom";
          }
          {
            keys = "Ctrl+b ←↓↑→";
            description = "Pane in that direction";
          }
          {
            keys = "Ctrl+b o";
            description = "Next pane";
          }
          {
            keys = "Ctrl+b z";
            description = "Zoom the pane";
          }
          {
            keys = "Ctrl+b x";
            description = "Kill the pane";
          }
          {
            keys = "Ctrl+b {";
            description = "Swap with the previous pane";
          }
          {
            keys = "Ctrl+b }";
            description = "Swap with the next pane";
          }
          {
            keys = "Ctrl+b !";
            description = "Break the pane into a window";
          }
          {
            keys = "Ctrl+b Space";
            description = "Next layout";
          }
          {
            keys = "Ctrl+b q";
            description = "Show pane numbers";
          }
        ];
      }
      {
        title = "Copy mode (vi)";
        binds = [
          {
            keys = "Ctrl+b [";
            description = "Enter copy mode";
          }
          {
            keys = "Space";
            description = "Start a selection";
          }
          {
            keys = "Enter";
            description = "Copy and leave";
          }
          {
            keys = "/";
            description = "Search down";
          }
          {
            keys = "?";
            description = "Search up";
          }
          {
            keys = "q";
            description = "Leave copy mode";
          }
          {
            keys = "Ctrl+b ]";
            description = "Paste";
          }
        ];
      }
      {
        title = "Other";
        binds = [
          {
            keys = "Ctrl+b :";
            description = "Command prompt";
          }
          {
            keys = "Ctrl+b ?";
            description = "List every key";
          }
          {
            keys = "Ctrl+b t";
            description = "Clock";
          }
        ];
      }
    ];
  };
}
