# modules/ui/keybinds/presets/neovim.nix
# Neovim: the base flavor of kukenan (github:juanalbarran/kukenan), from its
# docs/keybinds.md. The leader is Space. Language flavors add their own
# binds; a config adds them as groups of its own.
{
  flake.modules.homeManager.sarisarinama.programs.sarisarinama.keybinds.neovim = {
    label = "Neovim";
    icon = " ";
    order = 10;
    groups = [
      {
        title = "Files";
        binds = [
          {
            keys = "-";
            description = "File explorer (Oil)";
          }
          {
            keys = "Space e";
            description = "Toggle the file tree";
          }
          {
            keys = "Space f f";
            description = "Find files";
          }
          {
            keys = "Space f b";
            description = "Find open buffers";
          }
          {
            keys = "Space f w";
            description = "Grep the word under the cursor";
          }
          {
            keys = "Space f g";
            description = "Grep the project";
          }
          {
            keys = "Space f r";
            description = "Resume the last search";
          }
          {
            keys = "Space f k";
            description = "Find keymaps";
          }
        ];
      }
      {
        title = "Buffers and windows";
        binds = [
          {
            keys = "Space b d";
            description = "Delete the buffer";
          }
          {
            keys = "Space b d a";
            description = "Delete every buffer";
          }
          {
            keys = "Space v s";
            description = "Vertical split";
          }
          {
            keys = "Space h s";
            description = "Horizontal split";
          }
          {
            keys = "Ctrl+h";
            description = "Window or tmux pane left";
          }
          {
            keys = "Ctrl+j";
            description = "Window or tmux pane below";
          }
          {
            keys = "Ctrl+k";
            description = "Window or tmux pane above";
          }
          {
            keys = "Ctrl+l";
            description = "Window or tmux pane right";
          }
        ];
      }
      {
        title = "Editing";
        binds = [
          {
            keys = "Esc";
            description = "Clear the search highlight";
          }
          {
            keys = "Space s r";
            description = "Search and replace";
          }
          {
            keys = "Space q";
            description = "Diagnostic float";
          }
          {
            keys = "Space a c";
            description = "Toggle OpenCode";
          }
          {
            keys = "Tab";
            description = "Next snippet field (insert)";
          }
          {
            keys = "Shift+Tab";
            description = "Previous snippet field (insert)";
          }
        ];
      }
      {
        title = "Surround";
        binds = [
          {
            keys = "y s {motion} {char}";
            description = "Add a surround";
          }
          {
            keys = "d s {char}";
            description = "Delete a surround";
          }
          {
            keys = "c s {old} {new}";
            description = "Change a surround";
          }
          {
            keys = "S {char}";
            description = "Surround the selection (visual)";
          }
          {
            keys = "g S {char}";
            description = "Surround it on new lines (visual)";
          }
        ];
      }
      {
        title = "LSP";
        binds = [
          {
            keys = "g d";
            description = "Go to definition";
          }
          {
            keys = "g D";
            description = "Go to declaration";
          }
          {
            keys = "g t d";
            description = "Go to type definition";
          }
          {
            keys = "g r";
            description = "References";
          }
          {
            keys = "g i";
            description = "Implementations";
          }
          {
            keys = "g s";
            description = "Document symbols";
          }
          {
            keys = "K";
            description = "Hover documentation";
          }
          {
            keys = "Space c a";
            description = "Code actions";
          }
          {
            keys = "Space r n";
            description = "Rename";
          }
          {
            keys = "Space s h";
            description = "Signature help";
          }
          {
            keys = "Ctrl+k";
            description = "Signature help (insert)";
          }
          {
            keys = "Space t h";
            description = "Toggle inlay hints";
          }
        ];
      }
      {
        title = "Debugger";
        binds = [
          {
            keys = "Space d c";
            description = "Continue or start";
          }
          {
            keys = "Space d o";
            description = "Step over";
          }
          {
            keys = "Space d i";
            description = "Step into";
          }
          {
            keys = "Space d x";
            description = "Step out";
          }
          {
            keys = "Space d b";
            description = "Toggle breakpoint";
          }
          {
            keys = "Space d B";
            description = "Conditional breakpoint";
          }
          {
            keys = "Space d u";
            description = "Toggle the debug UI";
          }
          {
            keys = "Space d r";
            description = "Open the REPL";
          }
          {
            keys = "Space d l";
            description = "Run the last session";
          }
          {
            keys = "Space d q";
            description = "End the session";
          }
        ];
      }
      {
        title = "Git";
        binds = [
          {
            keys = "Space z d";
            description = "Diff of uncommitted changes";
          }
          {
            keys = "Space z D";
            description = "Diff against main";
          }
        ];
      }
    ];
  };
}
