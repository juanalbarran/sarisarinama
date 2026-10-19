# modules/ui/lock/nixos.nix
# On NixOS the PAM service is the system's to declare: /etc/pam.d is built
# by NixOS, and Home Manager cannot write there. This adds the one line,
# with NixOS's default stack (pam_unix, through its own unix_chkpwd wrapper).
# Import modules.nixos.sarisarinama in the NixOS configuration.
{
  flake.modules.nixos.sarisarinama = {
    security.pam.services.sarisarinama-lock = {};
  };
}
