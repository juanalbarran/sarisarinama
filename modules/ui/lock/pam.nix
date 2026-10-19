# modules/ui/lock/pam.nix
# The PAM service the lock checks passwords against, off NixOS. Quickshell
# from Nix links Nix's libpam, which has two quirks on another distro:
#   1. pam_unix runs /run/wrappers/bin/unix_chkpwd, a NixOS path, so a
#      tmpfiles rule links it to the distro's own.
#   2. it does not understand `@include`, which every Ubuntu service uses,
#      so the service is one plain `include common-auth` line.
# Both need root, so activation asks for sudo, once. On NixOS the service
# comes from the NixOS module, see nixos.nix.
{
  flake.modules.homeManager.sarisarinama = {
    config,
    lib,
    ...
  }: let
    cfg = config.programs.sarisarinama;
  in {
    options.programs.sarisarinama.lock.pam.enable =
      lib.mkEnableOption "writing /etc/pam.d/sarisarinama-lock with sudo, for a distro other than NixOS"
      // {
        default = config.targets.genericLinux.enable;
        defaultText = lib.literalExpression "config.targets.genericLinux.enable";
      };

    config = lib.mkIf (cfg.enable && cfg.lock.pam.enable) {
      home.activation.sarisarinamaLockPam = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ ! -f /etc/tmpfiles.d/nix-wrappers.conf ]; then
          echo 'sarisarinama lock: writing /etc/tmpfiles.d/nix-wrappers.conf (sudo)'
          tmp=$(mktemp)
          printf '%s\n' \
            'd /run/wrappers 0755 root root -' \
            'd /run/wrappers/bin 0755 root root -' \
            'L+ /run/wrappers/bin/unix_chkpwd - - - - /sbin/unix_chkpwd' > "$tmp"
          run /usr/bin/sudo cp "$tmp" /etc/tmpfiles.d/nix-wrappers.conf
          rm -f "$tmp"
        fi
        if [ ! -e /run/wrappers/bin/unix_chkpwd ]; then
          run /usr/bin/sudo systemd-tmpfiles --create /etc/tmpfiles.d/nix-wrappers.conf
        fi
        if [ "$(cat /etc/pam.d/sarisarinama-lock 2>/dev/null)" != 'auth include common-auth' ]; then
          echo 'sarisarinama lock: writing /etc/pam.d/sarisarinama-lock (sudo)'
          run /usr/bin/sudo sh -c "echo 'auth include common-auth' > /etc/pam.d/sarisarinama-lock"
        fi
      '';
    };
  };
}
